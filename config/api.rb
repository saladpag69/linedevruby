secret = Rails.application.credentials.jwt_secret
payload = { data: 'test' }
token   = JWT.encode(payload, secret, 'HS256')
decoded_token = JWT.decode(token, secret, true, { algorithm: 'HS256' })
