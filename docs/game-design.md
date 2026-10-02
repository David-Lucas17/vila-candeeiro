# A Vigília do Candeeiro — documento de design

**Disciplina:** Desenvolvimento de Jogos Digitais
**Temática do semestre:** Noites Cabulosas no Ceará
**Trabalho:** 1º trabalho — demonstração de jogo
**Engine:** Godot 4.7.2 · GDScript

---

## 1. Pitch

Sertão central do Ceará, 1932 — ano da seca grande. Morreu o velho Firmino e,
pelo costume, corpo não se deixa sozinho nem no escuro até o dia clarear. Correu
no arruado que a casa tinha coisa, e quando deu dez da noite todo mundo já tinha
arranjado o que fazer longe. Sobrou o jogador, um candeeiro com pouco azeite e
oito horas de noite.

O jogo é a vigília: oito turnos, uma assombração por turno, e duas formas de
morrer.

## 2. Gênero e referência de mecânica

Jogo de turno com gerenciamento de recursos e informação incompleta — mesma
família do Resta 21 (turno, decisão, consequência imediata), mas em vez de
pontuação a tensão vem de duas barras que se puxam em sentidos opostos.

## 3. Regras

### Estado

| Recurso | Começa | Teto | Observação |
|---|---|---|---|
| Luz | 7 | 10 | chega a 0 → derrota |
| Medo | 2 | 10 | chega a 10 → derrota |
| Azeite | 5 | — | +3 de Luz por pingada |
| Sal | 3 | — | defesa de soleira |
| Cana | 2 | — | −4 de Medo, cobra 2 depois |

### Pressão constante

A cada hora, independentemente do que o jogador faça:

- o pavio queima **1 de Luz**;
- a noite cansa e o Medo sobe **1**.

Isso garante que não existe jogada neutra: passar o turno já custa.

### As cinco ações e os quatro tipos de assombração

Cada assombração pertence a um tipo, e cada tipo tem **uma** defesa correta:

| Tipo | O que é | Defesa | Dano se não defendida |
|---|---|---|---|
| Sombra | o escuro em si avança | Pingar azeite | 2 Medo · 2 Luz |
| Soleira | algo quer entrar | Jogar sal | 3 Medo · 1 Luz |
| Alma | é gente morta | Fazer uma oração | 3 Medo |
| Pânico | o inimigo é o próprio corpo | Tomar um trago | 4 Medo |

A quinta ação, **Escutar**, não defende: reduz o dano da hora pela metade
(arredondando para cima) e revela qual assombração vem na hora seguinte.

Acertar a defesa anula o dano e ainda segura 1 de Medo — o que neutraliza
exatamente o cansaço daquela hora. Quem lê bem a noite se mantém estável; quem
erra acumula.

### Informação incompleta

O jogador nunca vê o nome da assombração antes de agir. Vê um **presságio**, que
sugere o tipo:

- *"Vem um frio por baixo da porta, e lá fora a noite está quente."* → Soleira
- *"Encheu a sala um cheiro de vela benta…"* → Alma

Em 1 hora de cada 4 a noite não avisa nada (*"A noite fechou miúda"*). É nessas
horas que Escutar vale o turno.

### Vitória e derrota

- **Vitória:** sobreviver à 8ª hora (05h) com Luz > 0 e Medo < 10. Às 06h o galo canta.
- **Derrota por Luz = 0:** o escuro entra.
- **Derrota por Medo = 10:** o jogador corre para a noite e se perde.

Cada desfecho tem seu próprio texto de epílogo.

## 4. A estratégia que o jogo exige

O dilema central: **são 8 ações para 8 assombrações, mas o Medo também precisa de
ações para baixar** — e as duas ações que acalmam (orar, beber) só servem de
defesa contra dois dos quatro tipos.

- A oração acalma 3, mas custa 1 de Luz extra: orar é tempo no escuro.
- A cana resolve agora e cobra 2 na hora seguinte: coragem emprestada se paga.
- O azeite é combustível **e** defesa contra Sombra — gastá-lo na hora errada
  deixa o jogador sem defesa quando a sombra vier.
- Noites com muita Sombra/Soleira matam de Medo; noites com muita Alma/Pânico
  matam de escuro.

O baralho tem 17 assombrações e a noite sorteia 8, então a distribuição muda a
cada partida e não existe sequência decorada que sempre funcione.

## 5. Balanceamento verificado

`tools/balance_test.gd` joga 2000 noites por perfil de jogador:

| Perfil | Vitória | Morreu no escuro | Fugiu de medo |
|---|---|---|---|
| Chuta ação aleatória | 0,2% | 39,2% | 60,5% |
| Lê os presságios e escuta quando a noite não avisa | **72,5%** | 2,8% | 24,8% |
| Só toma trago e reza | 0,0% | 100% | 0,0% |
| Só pinga azeite | 0,1% | 0,0% | 99,8% |

(Os números oscilam 2 a 3 pontos entre execuções, porque o baralho é sorteado.)

Os dois perfis unidimensionais perdem **sempre**, e por causas opostas — é a
prova de que as duas barras precisam ser administradas juntas.

## 6. Regionalismo

### Lendas usadas como assombrações

- **Mão de Cabelo** — mão cabeluda que sai de baixo da cama/rede para pegar quem
  está deitado. Lenda de assustar criança, corrente no interior nordestino.
- **Caipora** — o assobio no mato; quem responde ao assobio é levado. Figura de
  origem indígena, protetora da caça.
- **Mula sem Cabeça** — casco de ferro na estrada à noite.
- **Encomendação das almas** — tradição real: grupos que saem à noite rezando
  pelos mortos. No jogo, a procissão vem na direção da casa e o jogador não
  reconhece nenhuma das vozes.

### Costumes de velório que viraram mecânica

- Corpo **nunca** fica sozinho nem no escuro até amanhecer — é a premissa do jogo.
- **Sal grosso na soleira** para segurar o que vem de fora — virou ação.
- **Espelho coberto com pano** quando há defunto em casa — virou assombração.
- **Terço nas mãos do morto** e oração em voz alta — virou ação.

### Contexto histórico

1932 é o ano da seca grande no Ceará. A escassez do jogo não é arbitrária: pouco
azeite, três punhados de sal e duas talagadas de cana são o que uma casa de taipa
daquele ano teria. A mecânica de recursos apertados é consequência do cenário
histórico, não uma regra solta.

### O que foi deixado de fora de propósito

**Cabra Cabriola** e **lobisomem** não aparecem — são as lendas que os colegas de
turma já estão usando. O objetivo foi ocupar um terreno diferente: lenda de
assombração doméstica em vez de criatura que persegue.

## 7. Escopo da demonstração

Está pronto e jogável: as 8 horas, as 5 ações, as 17 assombrações, os 4 tipos de
presságio, os 3 desfechos, tela de abertura, tela de regras e registro da noite.

Fora do escopo desta demo: mais de uma noite encadeada, personagens com atributos
diferentes e trilha gravada com instrumento real.
