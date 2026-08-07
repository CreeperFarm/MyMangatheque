# Appwrite OAuth HTTPS Fix (Infra)

## Objectif
- Corriger le `redirect_uri_mismatch` Google OAuth causé par un `redirect_uri=http://...` généré par Appwrite.
- Stabiliser le flux mobile OAuth et vérifier que la redirection OAuth est bien en `https://`.

## Symptôme confirmé
- Le header `Location` retourné par Appwrite contient:
  - `redirect_uri=http%3A%2F%2Fappwrite.mymangatheque.com%2Fv1%2Faccount%2Fsessions%2Foauth2%2Fcallback%2Fgoogle%2F69a59d8c003140f373d3`
- Le header `x-debug-fallback: true` apparaît.

## 1) Variables Appwrite a forcer
Dans le `.env` Appwrite (instance self-hosted):

```env
_APP_ENV=production
_APP_DOMAIN=appwrite.mymangatheque.com
_APP_OPTIONS_ROUTER_FORCE_HTTPS=enabled
_APP_OPTIONS_FORCE_HTTPS=enabled
```

Notes:
- `_APP_OPTIONS_FORCE_HTTPS` est deprecated depuis 1.7.0, mais utile pour compat API selon version/stack.
- `_APP_OPTIONS_ROUTER_FORCE_HTTPS` doit rester `enabled`.

Appliquer:

```bash
docker compose up -d
docker compose exec appwrite vars | grep -E "_APP_ENV|_APP_DOMAIN|_APP_OPTIONS_ROUTER_FORCE_HTTPS|_APP_OPTIONS_FORCE_HTTPS"
```

## 2) Reverse proxy (Nginx/Traefik/Cloudflare)
Le proxy frontal doit transmettre les bons headers HTTPS a Appwrite.

Exemple Nginx:

```nginx
location / {
    proxy_pass https://127.0.0.1:32443;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Forwarded-Port 443;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

Points critiques:
- Forward vers l'entrypoint HTTPS Appwrite/Traefik (pas HTTP interne pour l'endpoint public OAuth).
- `Host` et `X-Forwarded-Proto=https` sont obligatoires.

Cloudflare:
- SSL mode: `Full (strict)`.
- Ne pas faire d'origin en HTTP pour le sous-domaine Appwrite.

## 3) Google Cloud Console
Dans le client OAuth Google utilise par Appwrite (`client_id` vu dans la redirection):

URI autorisee exacte:

```text
https://appwrite.mymangatheque.com/v1/account/sessions/oauth2/callback/google/69a59d8c003140f373d3
```

## 4) Verification rapide (must pass)
Lancer:

```bash
bash tools/check_appwrite_oauth_redirect.sh appwrite.mymangatheque.com 69a59d8c003140f373d3
```

Resultat attendu:
- `redirect_uri` en `https` (PAS `http`).
- `x-debug-fallback` absent.

Commande manuelle equivalent:

```bash
curl -sS -D - -o /dev/null --get "https://appwrite.mymangatheque.com/v1/account/tokens/oauth2/google" \
  --data-urlencode "project=69a59d8c003140f373d3" \
  --data-urlencode "success=appwrite-callback-69a59d8c003140f373d3://oauth2success" \
  --data-urlencode "failure=appwrite-callback-69a59d8c003140f373d3://oauth2failure"
```

## 5) Validation mobile finale
1. Redemarrer l'app iOS.
2. Cliquer Google Sign-In.
3. Verifier absence de:
   - `redirect_uri_mismatch`
   - `x-debug-fallback` dans le test curl
4. Verifier qu'une session user Appwrite existe puis que la navigation revient sur `/profile`.

## 6) Etat API key invite (deja adapte)
- L'app tente desormais `/api/auth/keys/mobile` avec Bearer si dispo, sinon sans Bearer (invite).
- Si backend accepte invite, la home doit charger sans login.
