#!/bin/bash
# Script pour télécharger les fichiers de données Tesseract

echo "📥 Téléchargement des fichiers Tesseract OCR..."

# Créer le répertoire si nécessaire
mkdir -p assets/tessdata

# Télécharger eng.traineddata depuis GitHub
echo "📥 Téléchargement de eng.traineddata (~10MB)..."
if command -v wget > /dev/null; then
    wget -O assets/tessdata/eng.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/eng.traineddata
elif command -v curl > /dev/null; then
    curl -L -o assets/tessdata/eng.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/eng.traineddata
else
    echo "❌ Erreur: wget ou curl est requis"
    echo "Téléchargez manuellement depuis:"
    echo "https://github.com/tesseract-ocr/tessdata/raw/main/eng.traineddata"
    echo "Et placez le fichier dans assets/tessdata/"
    exit 1
fi

# Vérifier le téléchargement
if [ -f "assets/tessdata/eng.traineddata" ]; then
    file_size=$(du -h assets/tessdata/eng.traineddata | cut -f1)
    echo "✅ Téléchargement réussi! Taille: $file_size"
    echo "✅ Fichier: assets/tessdata/eng.traineddata"
else
    echo "❌ Échec du téléchargement"
    echo "Téléchargez manuellement depuis:"
    echo "https://github.com/tesseract-ocr/tessdata/raw/main/eng.traineddata"
    exit 1
fi

echo ""
echo "🎉 Configuration Tesseract terminée!"
echo "Lancez: flutter pub get && flutter run"
