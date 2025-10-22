#!/bin/bash
# Script para simular ataque SSH da VM atacante para VM alvo
# Executa 5 comandos comuns de reconhecimento

TARGET_IP="192.168.56.10"
TARGET_USER="vagrant"
SSH_KEY="/home/vagrant/.ssh/id_rsa"

echo "========================================"
echo "Iniciando simulação de ataque SSH"
echo "Alvo: ${TARGET_USER}@${TARGET_IP}"
echo "========================================"
echo ""

# Verifica se a chave SSH existe
if [ ! -f "$SSH_KEY" ]; then
    echo "Chave SSH não encontrada em $SSH_KEY"
    echo "Tentando usar a chave padrão do Vagrant..."
    SSH_KEY=""
    SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
else
    SSH_OPTS="-i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
fi

echo ">>> Comando 1: Identificar usuário atual (whoami)"
ssh $SSH_OPTS ${TARGET_USER}@${TARGET_IP} "whoami" 2>/dev/null
echo ""

echo ">>> Comando 2: Obter informações do sistema (uname -a)"
ssh $SSH_OPTS ${TARGET_USER}@${TARGET_IP} "uname -a" 2>/dev/null
echo ""

echo ">>> Comando 3: Listar interfaces de rede (ip addr)"
ssh $SSH_OPTS ${TARGET_USER}@${TARGET_IP} "ip addr show" 2>/dev/null
echo ""

echo ">>> Comando 4: Listar processos em execução (ps aux | head -15)"
ssh $SSH_OPTS ${TARGET_USER}@${TARGET_IP} "ps aux | head -15" 2>/dev/null
echo ""

echo ">>> Comando 5: Listar usuários do sistema (cat /etc/passwd | grep -v nologin | grep -v false)"
ssh $SSH_OPTS ${TARGET_USER}@${TARGET_IP} "cat /etc/passwd | grep -v nologin | grep -v false" 2>/dev/null
echo ""

echo "========================================"
echo "Simulação de ataque SSH concluída!"
echo "========================================"
