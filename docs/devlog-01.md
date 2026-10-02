# Devlog 01 — A Vigília do Candeeiro

*(texto pronto para o blog)*

---

## Trabalho de DJD — Noites Cabulosas no Ceará

Minha demo se chama **A Vigília do Candeeiro** e a ideia central é esta: você passa
o jogo inteiro sentado numa cadeira, velando um corpo.

Sertão central do Ceará, 1932, ano da seca grande. Morreu o velho Firmino na cama
dele, de tarde, sem agonia. Pelo costume daqui, corpo não se deixa sozinho nem no
escuro até o dia clarear — vela-se a noite toda, com reza e candeeiro aceso. Só
que correu no arruado que aquela casa tinha coisa, e quando deu dez da noite todo
mundo já tinha arranjado o que fazer bem longe. Sobrou você, um candeeiro com
pouco azeite, três punhados de sal, duas talagadas de cana e oito horas de noite.

O jogo é de turno, no estilo do Resta 21: oito horas, das 22h às 05h, e em cada
hora você escolhe **uma** ação. Às 06h o galo canta e você ganhou.

A diferença é que não tem pontuação — tem duas barras que se puxam pra lados
opostos. **Luz** e **Medo**. Se o candeeiro apagar, o escuro entra e leva você. Se
o medo encher, você abre a porta e corre pra noite, e aí o corpo fica sozinho, que
é justamente o que ninguém deve deixar acontecer. Toda hora que passa o pavio
queima um tanto de Luz e a noite acrescenta um tanto de Medo, faça você o que
fizer — então não existe turno de descanso.

Em cada hora vem uma assombração, e aqui entra a estratégia. Cada assombração é de
um tipo, e cada tipo tem **uma** defesa que funciona:

- **Sombra** — o escuro em si avança. Defesa: pingar azeite, porque chama grande
  não deixa sombra crescer.
- **Soleira** — tem coisa querendo entrar. Defesa: jogar sal grosso na soleira.
- **Alma** — é gente morta, não é bicho. Defesa: fazer uma oração.
- **Pânico** — o inimigo é o seu próprio corpo. Defesa: tomar um trago de cana.

Só que você **não vê** o nome da assombração antes de agir. Você vê um presságio,
e o presságio avisa torto. *"Vem um frio por baixo da porta, e lá fora a noite
está quente"* é soleira. *"Encheu a sala um cheiro de vela benta, e vela benta não
tem nenhuma acesa aqui"* é alma. Numa hora de cada quatro a noite não avisa nada,
e aí existe uma quinta ação: **escutar**. Escutar não defende — você apanha, só
apanha menos — mas descobre o que vem na hora seguinte.

O aperto do jogo é que são oito ações para oito assombrações, e o Medo também
precisa de ação pra baixar. A oração acalma, mas custa luz, porque orar é tempo no
escuro. A cana acalma na hora e cobra na hora seguinte, que é coragem emprestada.
O azeite é combustível e defesa ao mesmo tempo, então gastar na hora errada deixa
você sem defesa quando a sombra vier. Dá pra perder por ser medroso demais e dá
pra perder por ser corajoso demais.

### As lendas

Fugi de propósito do Cabra Cabriola e do lobisomem, que o pessoal da turma já está
usando. Fui buscar assombração de dentro de casa:

- a **Mão de Cabelo**, que sai de baixo da rede arranhando o chão de barro
  procurando tornozelo;
- o assobio do **Caipora** no pé de mandacaru, no terreiro — quem responde, vai;
- a **Mula sem Cabeça** passando na estrada de barro, com casco de ferro, numa
  região onde não existe cavalo ferrado;
- a **encomendação das almas**, que é tradição de verdade: gente que sai à noite
  rezando pelos mortos. No jogo a procissão vem vindo pro lado da casa e você não
  reconhece nenhuma daquelas vozes.

Os costumes do velório viraram mecânica, não cenário: o sal na soleira é ação, o
espelho coberto com pano é assombração, a oração em voz alta é ação. E a
escassez tem motivo histórico — em 1932 uma casa de taipa não teria mesmo mais que
um pouco de azeite e um resto de sal.

### Como está

A demo está jogável de ponta a ponta: as oito horas, as cinco ações, 17
assombrações diferentes (a noite sorteia 8, então cada partida é outra noite), os
presságios, os três desfechos com texto próprio, tela de abertura e uma tela de
regras chamada *"O que a vó ensinou"*.

Sobre o visual: não tem sprite nenhum no projeto. A parede de taipa é feita em
shader, com o barro e a palha gerados por ruído, e a luz do candeeiro cai com o
quadrado da distância, como luz de verdade. A mesa, o corpo coberto pelo lençol e
o candeeiro são desenhados em código, e a chama fica tremendo sozinha — quando a
barra de Luz baixa, a chama encolhe junto e a sala vai sumindo de verdade nas
beiradas. Quando o Medo sobe, a imagem começa a tremer de leve e a tela puxa pra um
vermelho de barro queimado.

O som também é todo sintetizado por mim, num script, sem sample baixado: o vento
batendo na taipa, o pavio queimando, o coração que só aparece quando o medo passa
da metade, o sino da capela no amanhecer. São catorze sons.

As telas estão em `docs/screenshots/`.

### Próximos passos

Fechar o balanceamento com mais gente jogando, e ver se vale encadear mais de uma
noite de vigília em vez de uma só.
