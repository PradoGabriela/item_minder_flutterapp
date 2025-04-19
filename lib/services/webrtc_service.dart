import 'dart:convert';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:item_minder_flutterapp/base/item.dart';
import 'package:hive/hive.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

part 'webrtc_service.g.dart';

enum ConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

@riverpod
class WebRTCService extends _$WebRTCService {
  late RTCPeerConnection _peerConnection;
  RTCDataChannel? _dataChannel;
  String? _peerId;
  ConnectionState _connectionState = ConnectionState.disconnected;
  final List<String> _connectionErrors = [];

  @override
  Future<void> build() async {
    await _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    } catch (e) {
      _addError('Firebase init failed: ${e.toString()}');
    }
  }

  Future<void> connectToPeer(String peerId) async {
    if (_connectionState == ConnectionState.connected) {
      await disconnect();
    }

    setState(() {
      _peerId = peerId;
      _connectionState = ConnectionState.connecting;
      _connectionErrors.clear();
    });

    try {
      await _createPeerConnection();
      await _setupDataChannel();
      await _createAndSendOffer();
    } catch (e) {
      _addError('Connection failed: ${e.toString()}');
      await disconnect();
    }
  }

  Future<void> _createPeerConnection() async {
    try {
      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          // Add your TURN servers here if needed
        ]
      });

      _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate.candidate != null) {
          _sendSignal({
            'type': 'candidate',
            'candidate': {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            },
          });
        }
      };

      _peerConnection.onIceConnectionState = (state) {
        if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
          _addError('ICE connection failed');
        }
      };

      _peerConnection.onConnectionState = (state) {
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
          _addError('Peer connection failed');
        }
      };

      _peerConnection.onDataChannel = (channel) {
        _setupIncomingDataChannel(channel);
      };
    } catch (e) {
      _addError('PeerConnection creation failed: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> _setupDataChannel() async {
    try {
      final dataChannelInit = RTCDataChannelInit()
        ..ordered = true
        ..maxRetransmits = 30
        ..protocol = 'appitem-protocol';

      _dataChannel = await _peerConnection.createDataChannel(
        'appitem-data',
        dataChannelInit,
      );

      _dataChannel!.onMessage = (RTCDataChannelMessage message) {
        _handleIncomingData(message.text);
      };

      _dataChannel!.onDataChannelState = (state) {
        if (state == RTCDataChannelState.RTCDataChannelClosed) {
          _addError('Data channel closed');
        }
      };
    } catch (e) {
      _addError('Data channel setup failed: ${e.toString()}');
      rethrow;
    }
  }

  void _setupIncomingDataChannel(RTCDataChannel channel) {
    _dataChannel = channel;
    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      _handleIncomingData(message.text);
    };
  }

  Future<void> _createAndSendOffer() async {
    try {
      final offer = await _peerConnection.createOffer();
      await _peerConnection.setLocalDescription(offer);
      await _sendSignal({
        'type': 'offer',
        'sdp': offer.sdp,
      });
    } catch (e) {
      _addError('Offer creation failed: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> sendAppItem(AppItem item) async {
    if (_connectionState != ConnectionState.connected) {
      _addError('Not connected to peer');
      return;
    }

    if (_dataChannel?.state != RTCDataChannelState.RTCDataChannelOpen) {
      _addError('Data channel not open');
      return;
    }

    try {
      final jsonData = jsonEncode(item.toJson());
      _dataChannel!.send(RTCDataChannelMessage(jsonData));
    } catch (e) {
      _addError('Failed to send item: ${e.toString()}');
    }
  }

  void _handleIncomingData(String data) {
    try {
      final jsonData = jsonDecode(data);
      final item = AppItem.fromJson(jsonData);
      _saveItemToHive(item);
    } catch (e) {
      _addError('Failed to process incoming data: ${e.toString()}');
    }
  }

  void _saveItemToHive(AppItem item) {
    try {
      final box = Hive.box<AppItem>('appItems');
      box.add(item);
    } catch (e) {
      _addError('Failed to save item: ${e.toString()}');
    }
  }

  Future<void> _handleSignal(Map<String, dynamic> signal) async {
    try {
      switch (signal['type']) {
        case 'offer':
          await _handleOffer(signal);
          break;
        case 'answer':
          await _handleAnswer(signal);
          break;
        case 'candidate':
          await _handleCandidate(signal);
          break;
      }
    } catch (e) {
      _addError('Signal handling failed: ${e.toString()}');
    }
  }

  Future<void> _handleOffer(Map<String, dynamic> signal) async {
    await _peerConnection.setRemoteDescription(
      RTCSessionDescription(signal['sdp'], 'offer'),
    );

    final answer = await _peerConnection.createAnswer();
    await _peerConnection.setLocalDescription(answer);

    await _sendSignal({
      'type': 'answer',
      'sdp': answer.sdp,
    });

    setState(() => _connectionState = ConnectionState.connected);
  }

  Future<void> _handleAnswer(Map<String, dynamic> signal) async {
    await _peerConnection.setRemoteDescription(
      RTCSessionDescription(signal['sdp'], 'answer'),
    );
    setState(() => _connectionState = ConnectionState.connected);
  }

  Future<void> _handleCandidate(Map<String, dynamic> signal) async {
    await _peerConnection.addCandidate(RTCIceCandidate(
      signal['candidate']['candidate'],
      signal['candidate']['sdpMid'],
      signal['candidate']['sdpMLineIndex'],
    ));
  }

  Future<void> _sendSignal(Map<String, dynamic> signal) async {
    try {
      if (_peerId == null) throw Exception('Peer ID not set');

      await FirebaseDatabase.instance
          .ref()
          .child('signals/$_peerId')
          .push()
          .set({
        ...signal,
        'from': const Uuid().v4(),
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      _addError('Signal sending failed: ${e.toString()}');
    }
  }

  Future<void> disconnect() async {
    try {
      await _dataChannel?.close();
      await _peerConnection.close();
      _dataChannel = null;
      _peerId = null;
    } catch (e) {
      _addError('Disconnection failed: ${e.toString()}');
    } finally {
      setState(() => _connectionState = ConnectionState.disconnected);
    }
  }

  void _addError(String message) {
    setState(() {
      _connectionErrors.add(message);
      _connectionState = ConnectionState.error;
    });
  }

  ConnectionState get connectionState => _connectionState;
  List<String> get connectionErrors => _connectionErrors;

  void setState(VoidCallback fn) {
    fn();
    ref.notifyListeners();
  }
}
