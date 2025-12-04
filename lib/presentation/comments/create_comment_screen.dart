import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'comment_provider.dart';

class CreateCommentScreen extends StatefulWidget {
  final int projectId;
  final int? parentId;

  const CreateCommentScreen({
    super.key,
    required this.projectId,
    this.parentId,
  });

  @override
  State<CreateCommentScreen> createState() => _CreateCommentScreenState();
}

class _CreateCommentScreenState extends State<CreateCommentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  List<File> _attachments = [];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          _attachments.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
        ),
      );
    }
  }

  Future<void> _pickFiles() async {
    try {
      // Pour les fichiers, on peut utiliser file_picker si nécessaire
      // Pour l'instant, on utilise seulement les images
      await _pickImages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_contentController.text.trim().isEmpty && _attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un commentaire ou joindre un fichier'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final commentProvider =
        Provider.of<CommentProvider>(context, listen: false);

    final success = await commentProvider.createComment(
      content: _contentController.text.trim(),
      parentId: widget.parentId,
      attachments: _attachments.isEmpty ? null : _attachments,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commentaire créé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            commentProvider.errorMessage ?? 'Erreur lors de la création',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentId == null
            ? 'Nouveau commentaire'
            : 'Répondre'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Champ de texte
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: widget.parentId == null
                      ? 'Votre commentaire'
                      : 'Votre réponse',
                  hintText: 'Tapez @ pour mentionner un utilisateur',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 16),

              // Pièces jointes
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Photos'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Fichiers'),
                    ),
                  ),
                ],
              ),
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _attachments.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(_attachments[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _attachments.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Info sur les mentions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha((255 * 0.1).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tapez @ suivi du nom pour mentionner un utilisateur',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bouton de soumission
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFB41839),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  widget.parentId == null
                      ? 'PUBLIER LE COMMENTAIRE'
                      : 'PUBLIER LA RÉPONSE',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

