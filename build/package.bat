7z a automl_windows-%AUTOML_VERSION%.zip *.q fresh util requirements.txt  LICENSE README.md
appveyor PushArtifact automl_windows-%AUTOML_VERSION%.zip
exit /b 0
