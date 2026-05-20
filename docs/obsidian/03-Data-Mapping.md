# Data Mapping API -> UI Legacy

## Objectif
Conserver l’UI existante sans réécriture massive en reconstruisant un format “legacy-compatible” côté client.

## Mapping principal
- `series`
  - API: `titleFr`, `coverUrl`, `subSeries`
  - UI legacy: `title`, `image`, `sub_series`
- `sub-series`
  - API: `titleFr`, `coverUrl`, `series`, `editors`
  - UI legacy: `title`, `image`, `serie`, `editor`
- `volumes`
  - API: `titleFr`, `tomeNumber`, `coverUrl`, `publicationDate`, `bookLink`, `infoVolume`, `contain`
  - UI legacy: `title`, `tome_number`, `image`, `release`, `book_link`, `info`, `contains`
- `authors/editors`
  - API: `coverUrl`, `jobs`
  - UI legacy: `image`, `job`

## Collections utilisateur
- `ownedVolumes` -> legacy `owned`:
  - `volumeId` -> `volume`
  - `readed`, `lended`, `lendedLabel`
  - `volume` (objet optionnel) placé dans `expand.volume`.
- `followedSubSeries` -> legacy `followed`:
  - `subSeriesId` -> `sub_serie`
  - `subSeries` (objet optionnel) placé dans `expand.sub_serie`.

## Reconstruction `expand`
Compatibilité assurée par `AppwriteConnector._appendExpand(...)`.

Exemples:
- `owned` + `expand=volume.sub_series.editor`
- `followed` + `expand=sub_serie`
- `sub_series` + `expand=authors,volumes,editor,serie`

## Normalisation image
- Priorité: `coverUrl`.
- Fallback: `image` legacy.
- Suppression des URLs hardcodées `api/files/...`.

## Pagination
- Catalogue: pagination automatique `page/limit` jusqu’à `totalPages`.
- User collections: endpoints dédiés `/api/users/me/*` non paginés.

## Fichiers clés
- `lib/src/back/services/appwrite.dart`
- `lib/src/back/services/api/mobile_api_client.dart`
- `lib/src/back/services/models/api_record_model.dart`
