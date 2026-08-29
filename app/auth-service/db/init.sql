CREATE TABLE IF NOT EXISTS api_keys (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    
    -- key_hash armazena o hash SHA-256 da chave, que tem 64 caracteres hexadecimais
    key_hash VARCHAR(64) NOT NULL UNIQUE, 
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Chave de serviço interno usada pela evaluation-service (e testes de integração)
-- Valor da chave: tm_key_local-service-account-key
INSERT INTO api_keys (name, key_hash) VALUES
  ('service-account', 'd55fff45daf174019858934e5b8d81285b97092a8b1ca56dbc5b099622330097')
ON CONFLICT (key_hash) DO NOTHING;