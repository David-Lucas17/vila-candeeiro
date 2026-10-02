# Decisões — A Vigília do Candeeiro

### [2026-10-02] Vigília de velório em vez de perseguição
**Contexto:** a turma já tinha Cabra Cabriola em jogo de cartas (Eduardo) e
lobisomem em dois trabalhos (Bolívar, em corrida; Agaci, em investigação top-down).
O professor só aceita atividades estritamente diferentes.
**Decisão:** jogo de turno estático — o jogador fica sentado velando um corpo, e a
ameaça vem até ele. Lendas de assombração doméstica (Mão de Cabelo, Caipora, Mula
sem Cabeça, encomendação das almas) em vez de criatura perseguidora.
**Escopo:** temática e mecânica centrais do 1º trabalho.

### [2026-10-02] Duas barras em oposição em vez de pontuação
**Contexto:** era preciso ter "estratégia mínima" e regras de vitória/derrota bem
definidas, como pede o enunciado.
**Decisão:** Luz e Medo, cada uma com sua derrota própria, e pressão automática em
ambas a cada hora. As ações que salvam uma barra custam a outra.
**Escopo:** sistema de regras.

### [2026-10-02] Regras separadas da interface
**Contexto:** no Resta 21 a lógica e a tela estavam no mesmo script, o que
impedia testar sem abrir o jogo.
**Decisão:** `vigil.gd` não conhece nó nenhum. Permitiu rodar 8000 partidas
simuladas para calibrar o balanceamento e testar a interface headless.
**Escopo:** arquitetura do projeto.

### [2026-10-02] Zero asset de terceiros
**Contexto:** não havia tempo nem material para desenhar sprites e gravar áudio,
e asset baixado traz questão de licença no trabalho.
**Decisão:** parede e luz em shader, sala em `_draw()`, e os 14 sons sintetizados
por script Python com a biblioteca padrão.
**Escopo:** arte e áudio.
**Trade-off aceito:** visual mais abstrato do que arte desenhada, em troca de
autoria integral e de poder ajustar tudo por número.

### [2026-10-02] Layout das cenas gerado por script
**Contexto:** montar a tela no editor exigiria refazer tudo à mão a cada mudança
de composição.
**Decisão:** `tools/build_scenes.gd` monta a árvore e salva os `.tscn`. Os
arquivos gerados continuam abrindo e editáveis no editor.
**Escopo:** cenas `menu.tscn` e `game.tscn`.
**Trade-off aceito:** editar layout pelo editor é possível, mas regerar
sobrescreve — então mudança duradoura vai no gerador.
