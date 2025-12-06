# PCS3225 - Sistemas Digitais 2 - AF12 - Projeto do Processador PoliLEGv8 Monociclo (grupo T1G08)

**Integrantes:**
- André Saliba **NUSP:** 15439911
- Arthur Damásio **NUSP:** 15635138
- João Vítor Rocha **NUSP:** 15638465
- Henrique Falcão **NUSP:** 15459010
- Pedro Beraldo **NUSP:** 15484328
- Thiago Medeiros **NUSP:** 15651404

---
## Parte 1 Biblioteca de Componentes Básicos do PoliLEG*v*8

Nessa primeira etapa do projeto serão desenvolvidas as peças fundamentais para um processador, e no decorrer do projeto ela serão usadas para contruir as estruturas do fluxo de dados, como a ULA de 64 bits e o banco de registradores. Nesse sentido, seguem a baixo a declaração so 8 componentes a serem criados,em que serão especificados: (i.) descrição funcional do projeto (interfaces e lógica interna), (ii.) descrição do plano de testes, (iii.) descrição da bancada de testes e (iv.) apresentação e análise de conformidade dos resultados obtidos.

---
### Componente 1 - **Registrador**
1) Descrição funcional do projeto 

    Este componente atua como a unidade fundamental de memória de estado do processador. Trata-se de um registrador de carga paralela parametrizável (dataSize), projetado para operar de forma síncrona à borda de subida do clock, com um mecanismo de reset assíncrono para inicialização imediata do sistema. No contexto do PoliLEGv8, sua utilidade é crítica: ele será a base para a construção do Program Counter (PC), que rastreia a instrução atual, e do Banco de Registradores (Register File), que armazena as variáveis temporárias e operandos durante a execução das instruções. A presença do sinal enable é vital para garantir que a escrita de novos dados ocorra apenas quando instruída pela unidade de controle, preservando o estado do processador nos demais ciclos.

2) Descrição do plano de testes

    a

3) Descrição da bancada de testes

    a

4) Análise dos resultados obtidos

    a

---
### Componente 2 - **Multiplexador**
1) Descrição funcional do projeto 

    O multiplexador funciona como o "controlador de tráfego" do fluxo de dados. É um circuito combinacional que seleciona uma entre duas entradas de dados (in0 ou in1) para ser transmitida à saída dOut, baseando-se no estado de um sinal de seleção sel. No produto final, sua função é garantir a flexibilidade do datapath. Ele será utilizado, por exemplo, para decidir se a ULA receberá um dado vindo de um registrador ou um valor imediato vindo da instrução, ou ainda para definir qual endereço será gravado no PC (o da próxima instrução sequencial ou o de um desvio condicional), sendo, portanto, essencial para a execução de diferentes tipos de instruções com o mesmo hardware.

2) Descrição do plano de testes

    a

3) Descrição da bancada de testes

    a

4) Análise dos resultados obtidos

    a
---
### Componente 3 - **Memória de Instruções**
1) Descrição funcional do projeto 

    Este componente representa o armazenamento do programa a ser executado, comportando-se como uma ROM (Read-Only Memory) inicializada via arquivo externo (datFileName). Sua arquitetura permite a leitura assíncrona: dado um endereço de entrada addr, a instrução correspondente de 32 bits é disponibilizada no barramento data. No ciclo do PoliLEGv8, este é o ponto de partida de qualquer operação (fase de Fetch). É daqui que o processador busca o código de máquina que será decodificado para gerar os sinais de controle que governam o restante do sistema.

2) Descrição do plano de testes

    a

3) Descrição da bancada de testes

    a

4) Análise dos resultados obtidos

    a
---
### Componente 4 - **Memória de Dados**
1) Descrição funcional do projeto 

    Enquanto o banco de registradores armazena dados temporários de acesso rápido, a Memória de Dados atua como o armazenamento massivo do sistema (equivalente à RAM). O componente permite escrita síncrona (controlada por clock e sinal wr) e leitura assíncrona, operando com endereçamento por byte . No processador monociclo, este componente é indispensável para as instruções de acesso à memória, como LDUR (load) e STUR (store), permitindo que o processador manipule estruturas de dados complexas e variáveis que excedam a capacidade dos registradores internos.

2) Descrição do plano de testes

    a

3) Descrição da bancada de testes

    a

4) Análise dos resultados obtidos

    a
---
### Componente 5 - **Somador Binário**
1) Descrição funcional do projeto 

    Este é um circuito aritmético dedicado à soma pura de dois vetores de bits, sem a complexidade de sinais de controle de uma ULA completa e sem entrada de carry-in. No projeto do PoliLEGv8, a utilidade deste somador é estratégica e separada da execução lógica de dados: ele é empregado especificamente no cálculo de endereços. Uma instância será usada para incrementar o PC constantemente (PC + 4) para apontar para a próxima instrução, enquanto outra instância calculará o endereço de destino em instruções de desvio (branches), somando o PC atual ao offset da instrução.

2) Descrição do plano de testes

    a

3) Descrição da bancada de testes

    a

4) Análise dos resultados obtidos

    a
---
### Componente 6 - **ULA de 1 Bit**
1) Descrição funcional do projeto 

    A Unidade Lógica e Aritmética (ULA) de 1 bit é a célula fundamental de processamento. Projetada de forma modular, ela integra operações lógicas (AND, OR) e aritméticas (Soma), além da função Pass B, selecionáveis via multiplexador interno. Sua importância reside na escalabilidade: ao conectar 64 destas unidades em cascata (lidando com a propagação de carry), constrói-se a ULA principal do processador. É este componente que efetivamente "executa" as instruções lógico-aritméticas do código (como ADD, SUB, AND), transformando os dados brutos em resultados úteis e gerando flags de estado como Zero e Overflow.

2) Descrição do plano de testes

    a

3) Descrição da bancada de testes

    a

4) Análise dos resultados obtidos

    a
---
### Componente 7 - **Extensor de Sinal com Tamanho Configurável**
1) Descrição funcional do projeto 

    Este componente resolve a discrepância entre o tamanho das instruções (32 bits) e a arquitetura do processador (64 bits). Ele extrai um campo específico de bits da entrada e o expande para 64 bits, replicando o bit de sinal (MSB) nas posições superiores . Sua utilidade no PoliLEGv8 é crucial para decodificar valores imediatos contidos nas instruções (como constantes em somas ou offsets de memória). Sem a extensão de sinal correta, operações aritméticas com números negativos constantes ou acessos relativos à memória resultariam em valores incorretos ao serem processados pela ULA de 64 bits.

2) Descrição do plano de testes

    a

3) Descrição da bancada de testes

    a

4) Análise dos resultados obtidos

    a
---
### Componente 8 - **Deslocador Assíncrono de 2 Bits à Esquerda**
1) Descrição funcional do projeto 

    O deslocador realiza uma operação simples de shift left lógico de 2 bits, preenchendo as posições vazias com zeros. Embora simples, sua função é vital para o endereçamento do processador. Como o PoliLEGv8 endereça a memória byte a byte, mas as instruções possuem 4 bytes (32 bits), os endereços de desvio armazenados nas instruções representam contagens de palavras, não de bytes. Este componente converte esse valor, multiplicando-o por 4 (o equivalente binário a deslocar 2 bits à esquerda), garantindo que os saltos de programa (branches) aterrissem corretamente no início de uma instrução válida.

2) Descrição do plano de testes

    a

3) Descrição da bancada de testes

    a

4) Análise dos resultados obtidos

    a
---

