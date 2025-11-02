# Segurança de Redes — Laboratório SSH Hardening

- Repositório com ambiente Vagrant + scripts para demonstrar hardening SSH (fail2ban, UFW, etc.) e ataques controlados (enumeração, brute-force, evasão de logs, roubo de chaves).
- Documento principal: [documents/latex/main.tex](documents/latex/main.tex).

Requisitos
- Vagrant (2.x) — ver [src/Vagrantfile](src/Vagrantfile)  
- VirtualBox (6.x)  
- Ferramentas na VM atacante: ssh, sshpass, timeout, nmap (instaladas no provisionamento)  
- Host: Git, make, capacidade de rodar VMs (Memória/CPU suficiente)

Estrutura do repositório
- [documents/latex/main.tex](documents/latex/main.tex) — relatório em LaTeX (documentação dos testes)  
- [src/Vagrantfile](src/Vagrantfile) — definição das VMs (alvo, alvo-hardened, atacante)  
- Scripts de ataque / teste (na VM atacante):
  - `ataque_ssh.sh` — reconhecimento via SSH
  - `ataque_enumeracao_usuarios.sh` — enumeração de usuários
  - `teste_brute_force.sh` — teste de brute-force; função principal: `test_ssh_bruteforce`
  - `ataque_evasao_logs.sh` — evasão/manipulação de logs
  - `ataque_roubo_chaves_ssh.sh` — busca/exfiltração de chaves SSH
- Metadados Vagrant: `src/.vagrant/`

Quick start (reproduzir laboratório)
1. Subir VMs
   ```sh
   cd src
   vagrant up
   ```
   - O provisionamento instala as ferramentas na VM atacante e configura as VMs alvo.
   - Aguarde até o provisionamento terminar (pode demorar alguns minutos).

2. Acessar a VM atacante
   ```sh
   vagrant ssh atacante
   ```
   - Os scripts estão disponíveis na pasta sincronizada (p.ex. `/vagrant` ou `/vagrant/src` dentro da VM). Ajuste o caminho conforme seu Vagrantfile.

3. Exemplos de uso dos scripts (executar dentro da VM atacante)
   - Reconhecimento SSH (testes de conexão simples / banner)
     ```sh
     ./ataque_ssh.sh <IP_ALVO>
     ```
   - Enumeração de usuários
     ```sh
     ./ataque_enumeracao_usuarios.sh <IP_ALVO> <lista_usuarios.txt>
     ```
   - Teste de brute-force (exemplo genérico)
     ```sh
     ./teste_brute_force.sh <IP_ALVO> <usuario> <lista_senhas.txt>
     ```
     - O script contém a função `test_ssh_bruteforce`; confira cabeçalho do script para parâmetros e opções adicionais.
   - Evasão / manipulação de logs
     ```sh
     sudo ./ataque_evasao_logs.sh <IP_ALVO>
     ```
     - Requer privilégios dependendo das ações simuladas.
   - Busca/exfiltração de chaves SSH
     ```sh
     ./ataque_roubo_chaves_ssh.sh <IP_ALVO>
     ```

Observações sobre parâmetros
- Os scripts aceitam argumentos posicionais; leia os comentários/instruções no início de cada arquivo para detalhes específicos.
- Para testes automatizados, combine `timeout`/`sshpass` conforme necessário.

Layout de rede (resumo)
- O Vagrantfile cria ao menos três VMs: atacante, alvo (não hardened) e alvo-hardened.
- As VMs compartilham uma rede privada para possibilitar os testes sem afetar a rede externa.

Boas práticas e segurança
- Este laboratório destina-se apenas a ambientes controlados e para fins educacionais.
- Não execute esses scripts ou técnicas contra sistemas sem autorização explícita.
- Isole o ambiente da rede de produção e use snapshots/rollbacks das VMs para recuperação.

Limpeza / destruir VMs
```sh
cd src
vagrant destroy -f
```
- Use `vagrant halt` para parar sem destruir.

Soluções e resultados esperados
- O relatório em `documents/latex/main.tex` documenta os passos e os resultados das diferentes técnicas e hardening aplicados.
- Ao comparar o alvo padrão e o alvo-hardened você deve observar diferenças em:
  - Resposta a tentativas de brute-force (fail2ban, limites)
  - Disponibilidade de contas e enumeração de usuários
  - Logs e possibilidade de evasão
  - Presença/permissões de chaves SSH

Resolução de problemas
- Se o `vagrant up` travar, veja logs em `src/.vagrant` e confirme versão do VirtualBox.
- Se scripts falharem por falta de dependência, verifique provisionamento ou instale manualmente (p.ex. `sudo apt update && sudo apt install -y sshpass nmap`).
