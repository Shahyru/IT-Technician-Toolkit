import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/services/qr_service.dart';
import '../../../core/utils/clipboard_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/favorite_button.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  QrContentType _type = QrContentType.wifi;

  // Wi-Fi inputs
  final TextEditingController _wifiSsidController = TextEditingController(text: 'Office-Staff-5G');
  final TextEditingController _wifiPassController = TextEditingController(text: 'NetworkSecure2026!');
  WifiSecurity _wifiSecurity = WifiSecurity.wpa;
  bool _wifiHidden = false;

  // Plain text / URL
  final TextEditingController _textController = TextEditingController(text: 'https://github.com');

  // Email
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _emailSubjectController = TextEditingController();

  // Phone
  final TextEditingController _phoneController = TextEditingController();

  // vCard
  final TextEditingController _vCardFirstController = TextEditingController(text: 'Alex');
  final TextEditingController _vCardLastController = TextEditingController(text: 'Tech');
  final TextEditingController _vCardOrgController = TextEditingController(text: 'IT Support Team');
  final TextEditingController _vCardPhoneController = TextEditingController(text: '+1-555-0199');

  String _qrData = '';

  @override
  void initState() {
    super.initState();
    _rebuildQrData();
  }

  @override
  void dispose() {
    _wifiSsidController.dispose();
    _wifiPassController.dispose();
    _textController.dispose();
    _emailAddressController.dispose();
    _emailSubjectController.dispose();
    _phoneController.dispose();
    _vCardFirstController.dispose();
    _vCardLastController.dispose();
    _vCardOrgController.dispose();
    _vCardPhoneController.dispose();
    super.dispose();
  }

  void _rebuildQrData() {
    String payload = '';
    switch (_type) {
      case QrContentType.wifi:
        payload = QrService.buildWifiPayload(
          ssid: _wifiSsidController.text.trim(),
          password: _wifiPassController.text,
          security: _wifiSecurity,
          isHidden: _wifiHidden,
        );
        break;
      case QrContentType.url:
      case QrContentType.plainText:
        payload = _textController.text.trim();
        break;
      case QrContentType.email:
        payload = QrService.buildEmailPayload(
          email: _emailAddressController.text.trim(),
          subject: _emailSubjectController.text.trim(),
        );
        break;
      case QrContentType.phone:
        payload = QrService.buildPhonePayload(_phoneController.text.trim());
        break;
      case QrContentType.sms:
        payload = QrService.buildSmsPayload(
          phone: _phoneController.text.trim(),
          message: _textController.text.trim(),
        );
        break;
      case QrContentType.vCard:
        payload = QrService.buildVCardPayload(
          firstName: _vCardFirstController.text.trim(),
          lastName: _vCardLastController.text.trim(),
          organization: _vCardOrgController.text.trim(),
          phone: _vCardPhoneController.text.trim(),
        );
        break;
    }

    setState(() => _qrData = payload);
  }

  void _clear() {
    setState(() {
      _wifiSsidController.clear();
      _wifiPassController.clear();
      _textController.clear();
      _emailAddressController.clear();
      _emailSubjectController.clear();
      _phoneController.clear();
      _vCardFirstController.clear();
      _vCardLastController.clear();
      _vCardOrgController.clear();
      _vCardPhoneController.clear();
      _qrData = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local QR Code Generator'),
        actions: const [
          FavoriteButton(itemId: 'tool-qr-gen'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Content Type Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _typeChip(QrContentType.wifi, 'Wi-Fi Network', Icons.wifi),
                  _typeChip(QrContentType.plainText, 'Plain Text', Icons.text_snippet),
                  _typeChip(QrContentType.url, 'URL / Link', Icons.link),
                  _typeChip(QrContentType.vCard, 'vCard Contact', Icons.contact_page),
                  _typeChip(QrContentType.email, 'Email', Icons.email),
                  _typeChip(QrContentType.phone, 'Phone Call', Icons.phone),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interactive Inputs Form
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payload Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      TextButton.icon(
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear'),
                        onPressed: _clear,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Wi-Fi Form
                  if (_type == QrContentType.wifi) ...[
                    TextFormField(
                      controller: _wifiSsidController,
                      decoration: const InputDecoration(labelText: 'Network SSID (Name)', prefixIcon: Icon(Icons.wifi)),
                      onChanged: (_) => _rebuildQrData(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _wifiPassController,
                      decoration: const InputDecoration(labelText: 'Pre-Shared Key / Password', prefixIcon: Icon(Icons.password)),
                      onChanged: (_) => _rebuildQrData(),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<WifiSecurity>(
                      value: _wifiSecurity,
                      decoration: const InputDecoration(labelText: 'Security Protocol'),
                      items: const [
                        DropdownMenuItem(value: WifiSecurity.wpa, child: Text('WPA / WPA2 / WPA3')),
                        DropdownMenuItem(value: WifiSecurity.wep, child: Text('WEP (Legacy)')),
                        DropdownMenuItem(value: WifiSecurity.nopass, child: Text('Unsecured / Open')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _wifiSecurity = val);
                          _rebuildQrData();
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    CheckboxListTile(
                      title: const Text('Hidden SSID Network'),
                      value: _wifiHidden,
                      onChanged: (val) {
                        setState(() => _wifiHidden = val ?? false);
                        _rebuildQrData();
                      },
                    ),
                  ],

                  // Plain Text / URL Form
                  if (_type == QrContentType.plainText || _type == QrContentType.url) ...[
                    TextFormField(
                      controller: _textController,
                      maxLines: _type == QrContentType.plainText ? 4 : 1,
                      decoration: InputDecoration(
                        labelText: _type == QrContentType.url ? 'URL Destination' : 'Raw Text Payload',
                        hintText: _type == QrContentType.url ? 'https://example.com' : 'Enter plain text message...',
                        prefixIcon: Icon(_type == QrContentType.url ? Icons.link : Icons.notes),
                      ),
                      onChanged: (_) => _rebuildQrData(),
                    ),
                  ],

                  // Email Form
                  if (_type == QrContentType.email) ...[
                    TextFormField(
                      controller: _emailAddressController,
                      decoration: const InputDecoration(labelText: 'Recipient Email Address', prefixIcon: Icon(Icons.email)),
                      onChanged: (_) => _rebuildQrData(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailSubjectController,
                      decoration: const InputDecoration(labelText: 'Subject Line', prefixIcon: Icon(Icons.subject)),
                      onChanged: (_) => _rebuildQrData(),
                    ),
                  ],

                  // Phone Form
                  if (_type == QrContentType.phone) ...[
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                      onChanged: (_) => _rebuildQrData(),
                    ),
                  ],

                  // vCard Form
                  if (_type == QrContentType.vCard) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _vCardFirstController,
                            decoration: const InputDecoration(labelText: 'First Name'),
                            onChanged: (_) => _rebuildQrData(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _vCardLastController,
                            decoration: const InputDecoration(labelText: 'Last Name'),
                            onChanged: (_) => _rebuildQrData(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _vCardOrgController,
                      decoration: const InputDecoration(labelText: 'Organization / Company', prefixIcon: Icon(Icons.business)),
                      onChanged: (_) => _rebuildQrData(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _vCardPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                      onChanged: (_) => _rebuildQrData(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // QR Code Rendering Container
            Center(
              child: _qrData.isEmpty
                  ? const Text('Enter payload details above to generate QR Code', style: TextStyle(color: Colors.grey))
                  : Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: 240,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            if (_qrData.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => ClipboardUtils.copyWithFeedback(
                      context,
                      _qrData,
                      message: 'QR payload copied to clipboard',
                    ),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Payload'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _typeChip(QrContentType type, String label, IconData icon) {
    final selected = _type == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        selected: selected,
        onSelected: (val) {
          if (val) {
            setState(() => _type = type);
            _rebuildQrData();
          }
        },
      ),
    );
  }
}
