secret = Rails.application.credentials.jwt_secret

secret = "8aac94cbf2300f08dded822dc2176094a2f953e737eeca4a6d81920545dbf061ece67932da30ef8d8458691fde4795deba5f14e3caa00500a49a7935b4c812bd"
payload = { data: 'test' }
token   = JWT.encode(payload, secret, 'HS256')
decoded_token = JWT.decode(token, secret, true, { algorithm: 'HS256' })
