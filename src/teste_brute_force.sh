#!/bin/bash
# Script para testar proteção contra brute-force SSH
# Demonstra diferença entre alvo (vulnerável) e alvo-hardened (protegido)

echo "========================================"
echo "TESTE DE PROTEÇÃO CONTRA BRUTE-FORCE SSH"
echo "========================================"
echo ""

# Função para testar SSH com senha errada
test_ssh_bruteforce() {
    local TARGET_IP=$1
    local TARGET_NAME=$2
    
    echo ">>> Testando $TARGET_NAME ($TARGET_IP)"
    echo "Tentando 5 logins com senha ERRADA..."
    echo ""
    
    for i in {1..5}; do
        echo "Tentativa $i:"
        # Usa sshpass para automação (senha errada propositalmente)
        timeout 5 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                    -o ConnectTimeout=3 vagrant@$TARGET_IP "echo 'Conectado'" 2>&1 | \
                    grep -E "Permission denied|Connection refused|Connection timed out" || echo "Conectado com sucesso"
        sleep 1
    done
    
    echo ""
    echo "Verificando se ainda consigo conectar após 5 tentativas falhadas..."
    timeout 5 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                -o ConnectTimeout=3 vagrant@$TARGET_IP "echo 'Conexão permitida'" 2>&1 | \
                grep -E "Permission denied|Connection refused|Connection timed out" || echo "✓ Conexão ainda permitida"
    echo ""
    echo "----------------------------------------"
    echo ""
}

# Teste 1: VM ALVO (sem proteção)
echo "=== TESTE 1: VM ALVO (SEM PROTEÇÃO) ==="
test_ssh_bruteforce "192.168.56.10" "alvo"

# Teste 2: VM ALVO-HARDENED (com proteção)
echo "=== TESTE 2: VM ALVO-HARDENED (COM PROTEÇÃO) ==="
test_ssh_bruteforce "192.168.56.11" "alvo-hardened"

echo "========================================"
echo "VERIFICANDO LOGS DE FAIL2BAN"
echo "========================================"
echo "Acessando alvo-hardened para ver se IP foi banido..."
echo ""
