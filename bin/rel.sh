#!/bin/bash

MIEX_ENV=prod SECRET_KEY_BASE=p6mNyV2NyvZOBbWq/ox7cQsj2wgWDxkPlkRIArNbIn8WuRwmxpOlFMiO7yySWt2F DATABASE_URL=ecto://postgres:postgres@localhost/apollo APOLLO_SSL_KEY_PATH=priv/ssl/apollo.minasmazar.org-key.pem APOLLO_SSL_CERT_PATH=priv/ssl/apollo.minasmazar.org.pem _build/prod/rel/apollo/bin/server
