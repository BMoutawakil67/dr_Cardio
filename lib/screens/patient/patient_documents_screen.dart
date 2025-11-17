import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';

class PatientDocumentsScreen extends StatefulWidget {
  const PatientDocumentsScreen({super.key});

  @override
  State<PatientDocumentsScreen> createState() => _PatientDocumentsScreenState();
}

class _PatientDocumentsScreenState extends State<PatientDocumentsScreen> {
  String _selectedFilter = 'Tous';

  final List<MedicalDocument> _documents = [
    MedicalDocument(
      title: 'ECG',
      date: '15 Oct 2024',
      type: DocumentType.ecg,
      size: '2.3 MB',
      sharedWithDoctor: true,
    ),
    MedicalDocument(
      title: 'MAPA (24h)',
      date: '10 Oct 2024',
      type: DocumentType.mapa,
      size: '5.1 MB',
      sharedWithDoctor: true,
    ),
    MedicalDocument(
      title: 'Bilan sanguin',
      date: '5 Oct 2024',
      type: DocumentType.bloodTest,
      size: '1.8 MB',
      sharedWithDoctor: true,
    ),
    MedicalDocument(
      title: 'Ordonnance',
      date: '1 Oct 2024',
      type: DocumentType.prescription,
      size: '0.5 MB',
      sharedWithDoctor: false,
    ),
    MedicalDocument(
      title: 'Radiographie thoracique',
      date: '20 Sep 2024',
      type: DocumentType.xray,
      size: '3.2 MB',
      sharedWithDoctor: true,
    ),
    MedicalDocument(
      title: 'Compte rendu consultation',
      date: '15 Sep 2024',
      type: DocumentType.consultation,
      size: '0.8 MB',
      sharedWithDoctor: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDocuments = _getFilteredDocuments();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents Médicaux'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Tous', child: Text('Tous')),
              const PopupMenuItem(value: 'ECG', child: Text('ECG')),
              const PopupMenuItem(value: 'MAPA', child: Text('MAPA')),
              const PopupMenuItem(value: 'Analyses', child: Text('Analyses')),
              const PopupMenuItem(value: 'Ordonnances', child: Text('Ordonnances')),
              const PopupMenuItem(value: 'Imagerie', child: Text('Imagerie')),
              const PopupMenuItem(value: 'Partagés', child: Text('Partagés avec médecin')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Info bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${filteredDocuments.length} document${filteredDocuments.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des documents
          Expanded(
            child: filteredDocuments.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDocuments.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _DocumentCard(
                        document: filteredDocuments[index],
                        onTap: () => _viewDocument(filteredDocuments[index]),
                        onShare: () => _shareDocument(filteredDocuments[index]),
                        onDelete: () => _deleteDocument(filteredDocuments[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDocument,
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: AppTheme.greyMedium.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun document',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.greyMedium.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez vos documents médicaux\npour les consulter facilement',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.greyMedium.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  List<MedicalDocument> _getFilteredDocuments() {
    if (_selectedFilter == 'Tous') {
      return _documents;
    } else if (_selectedFilter == 'Partagés') {
      return _documents.where((doc) => doc.sharedWithDoctor).toList();
    } else {
      return _documents.where((doc) {
        switch (_selectedFilter) {
          case 'ECG':
            return doc.type == DocumentType.ecg;
          case 'MAPA':
            return doc.type == DocumentType.mapa;
          case 'Analyses':
            return doc.type == DocumentType.bloodTest;
          case 'Ordonnances':
            return doc.type == DocumentType.prescription;
          case 'Imagerie':
            return doc.type == DocumentType.xray;
          default:
            return true;
        }
      }).toList();
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher un document'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Nom du document...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la recherche
            },
            child: const Text('Rechercher'),
          ),
        ],
      ),
    );
  }

  void _viewDocument(MedicalDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(document.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${document.date}'),
            const SizedBox(height: 8),
            Text('Taille: ${document.size}'),
            const SizedBox(height: 8),
            Text(
              document.sharedWithDoctor
                  ? '✓ Partagé avec votre médecin'
                  : '✗ Non partagé',
              style: TextStyle(
                color: document.sharedWithDoctor
                    ? AppTheme.successGreen
                    : AppTheme.greyMedium,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.greyLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getDocumentIcon(document.type),
                    size: 64,
                    color: AppTheme.greyMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('[Aperçu du document]'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Télécharger le document
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document téléchargé'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Télécharger'),
          ),
        ],
      ),
    );
  }

  void _shareDocument(MedicalDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partager avec votre médecin'),
        content: Text(
          document.sharedWithDoctor
              ? 'Ce document est déjà partagé avec votre médecin.'
              : 'Voulez-vous partager ce document avec votre médecin traitant?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          if (!document.sharedWithDoctor)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  document.sharedWithDoctor = true;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Document partagé avec succès'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
              child: const Text('Partager'),
            ),
        ],
      ),
    );
  }

  void _deleteDocument(MedicalDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le document'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${document.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _documents.remove(document);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document supprimé'),
                  backgroundColor: AppTheme.secondaryRed,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.secondaryRed),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _addDocument() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Prendre une photo');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir dans la galerie'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Choisir dans la galerie');
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Sélectionner un fichier'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Sélectionner un fichier');
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scanner un QR code'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Scanner un QR code');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Fonctionnalité en cours de développement'),
        backgroundColor: AppTheme.warningOrange,
      ),
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.ecg:
        return Icons.monitor_heart;
      case DocumentType.mapa:
        return Icons.analytics;
      case DocumentType.bloodTest:
        return Icons.science;
      case DocumentType.prescription:
        return Icons.medication;
      case DocumentType.xray:
        return Icons.image;
      case DocumentType.consultation:
        return Icons.description;
    }
  }
}

class _DocumentCard extends StatelessWidget {
  final MedicalDocument document;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _DocumentCard({
    required this.document,
    required this.onTap,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getTypeColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: _getTypeColor(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          document.date,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.greyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (document.sharedWithDoctor)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: AppTheme.successGreen,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Partagé',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    document.size,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.greyMedium,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      document.sharedWithDoctor ? Icons.share : Icons.share_outlined,
                      size: 20,
                      color: AppTheme.primaryBlue,
                    ),
                    onPressed: onShare,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppTheme.secondaryRed,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (document.type) {
      case DocumentType.ecg:
        return AppTheme.secondaryRed;
      case DocumentType.mapa:
        return AppTheme.primaryBlue;
      case DocumentType.bloodTest:
        return AppTheme.successGreen;
      case DocumentType.prescription:
        return AppTheme.warningOrange;
      case DocumentType.xray:
        return AppTheme.greyDark;
      case DocumentType.consultation:
        return AppTheme.primaryBlue;
    }
  }

  IconData _getTypeIcon() {
    switch (document.type) {
      case DocumentType.ecg:
        return Icons.monitor_heart;
      case DocumentType.mapa:
        return Icons.analytics;
      case DocumentType.bloodTest:
        return Icons.science;
      case DocumentType.prescription:
        return Icons.medication;
      case DocumentType.xray:
        return Icons.image;
      case DocumentType.consultation:
        return Icons.description;
    }
  }
}

enum DocumentType {
  ecg,
  mapa,
  bloodTest,
  prescription,
  xray,
  consultation,
}

class MedicalDocument {
  String title;
  String date;
  DocumentType type;
  String size;
  bool sharedWithDoctor;

  MedicalDocument({
    required this.title,
    required this.date,
    required this.type,
    required this.size,
    required this.sharedWithDoctor,
  });
}
