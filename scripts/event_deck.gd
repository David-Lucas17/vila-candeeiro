class_name EventDeck

static func build_deck():
	var deck = []

	deck.append(NightEvent.new(
		"O vulto no vão da cozinha",
		"Tem alguém de pé no vão da cozinha, parado, do tamanho de homem feito. Você pisca devagar pra se certificar. Continua lá.",
		NightEvent.Kind.SOMBRA, 2, 2))
	deck.append(NightEvent.new(
		"O escuro engrossa",
		"A sombra do oitão cresceu pra dentro da sala e não corresponde a móvel nenhum que exista nesta casa.",
		NightEvent.Kind.SOMBRA, 2, 2))
	deck.append(NightEvent.new(
		"A sombra de braço comprido",
		"Na parede de taipa a sua sombra repete os seus gestos, um por um. Com os braços um palmo mais longos.",
		NightEvent.Kind.SOMBRA, 2, 2))
	deck.append(NightEvent.new(
		"O candeeiro recua",
		"A chama se deita pra um lado só, como se tivesse alguém soprando bem devagar do outro lado da mesa.",
		NightEvent.Kind.SOMBRA, 2, 2))

	deck.append(NightEvent.new(
		"Bateram na janela",
		"Três batidas pausadas na janela do alpendre. Você conta todas. Lá fora não tem ninguém, e não tem lua.",
		NightEvent.Kind.SOLEIRA, 3, 1))
	deck.append(NightEvent.new(
		"A Mão de Cabelo",
		"Debaixo da rede, uma mão peluda arranha o chão de barro batido. Devagar, de um lado pro outro, procurando tornozelo.",
		NightEvent.Kind.SOLEIRA, 3, 1))
	deck.append(NightEvent.new(
		"A Mula sem Cabeça na estrada",
		"Casco de ferro na estrada de barro, vindo pro lado da casa. Em légua nenhuma daqui existe cavalo ferrado.",
		NightEvent.Kind.SOLEIRA, 3, 1))
	deck.append(NightEvent.new(
		"O assobio no mandacaru",
		"Um assobio fino vem do terreiro, do pé do mandacaru. É o Caipora chamando. Quem responde, vai com ele.",
		NightEvent.Kind.SOLEIRA, 3, 1))
	deck.append(NightEvent.new(
		"A porta que não fecha",
		"A porta da frente está trancada por dentro, com tramela e tudo. E está indo e vindo pra dentro, como fole de ferreiro.",
		NightEvent.Kind.SOLEIRA, 3, 1))

	deck.append(NightEvent.new(
		"A voz do finado",
		"O defunto chama o seu nome na voz de quando era vivo, pedindo água. Educado, como ele sempre foi.",
		NightEvent.Kind.ALMA, 3, 0))
	deck.append(NightEvent.new(
		"A encomendação das almas",
		"Longe, na estrada, um bando reza pelos mortos e vem vindo pra cá. Você conhece todo mundo deste arruado, e não reconhece nenhuma daquelas vozes.",
		NightEvent.Kind.ALMA, 3, 0))
	deck.append(NightEvent.new(
		"O lençol se mexeu",
		"O pano sobre o rosto do finado subiu e desceu. Uma vez só. Devagar.",
		NightEvent.Kind.ALMA, 3, 0))
	deck.append(NightEvent.new(
		"O terço andou",
		"O rosário que você enrolou nas mãos dele está agora na ponta da mesa, armado em forma de laço.",
		NightEvent.Kind.ALMA, 3, 0))

	deck.append(NightEvent.new(
		"O Piaba parou de latir",
		"O cachorro latia desde que escureceu. Parou no meio de um latido, e o silêncio que sobrou é pior que o latido.",
		NightEvent.Kind.PANICO, 4, 0))
	deck.append(NightEvent.new(
		"O silêncio de dentro do peito",
		"Você se dá conta de que está há muito tempo sem respirar e não consegue lembrar quando foi que parou.",
		NightEvent.Kind.PANICO, 4, 0))
	deck.append(NightEvent.new(
		"O pano do espelho",
		"O espelho da sala está coberto de pano, como manda o costume de quando tem defunto em casa. O pano está se mexendo.",
		NightEvent.Kind.PANICO, 4, 0))
	deck.append(NightEvent.new(
		"O relógio do coração",
		"O coração bateu três vezes no seu ouvido, não no peito. Você escuta ele de fora do corpo.",
		NightEvent.Kind.PANICO, 4, 0))

	return deck

static func omen_for(kind):
	var omens = []
	match kind:
		NightEvent.Kind.SOMBRA:
			omens = [
				"A chama baixou sozinha, e a luz não chega mais na parede do fundo.",
				"O escuro dos cantos da sala parece mais cheio do que vazio.",
				"Tem menos luz nesta sala do que o azeite que você já gastou explica.",
			]
		NightEvent.Kind.SOLEIRA:
			omens = [
				"Vem um frio por baixo da porta, e lá fora a noite está quente.",
				"O barro do terreiro rangeu. Duas vezes, no mesmo lugar.",
				"Os bichos do oitão calaram todos de uma vez, pro lado de fora da casa.",
			]
		NightEvent.Kind.ALMA:
			omens = [
				"Encheu a sala um cheiro de vela benta, e vela benta não tem nenhuma acesa aqui.",
				"Tem um zumbido de reza no seu ouvido, rezado por muita gente junto.",
				"A água do copo ao lado do finado tremeu sem ninguém encostar.",
			]
		_:
			omens = [
				"Seu corpo está estranho. As mãos não parecem suas.",
				"O coração bate alto e fora de hora, e não é por causa de nada que você viu.",
				"Deu uma fraqueza nos joelhos, do nada, como quem vai desmaiar de pé.",
			]
	return omens[randi() % omens.size()]

static func vague_omen():
	var omens = [
		"A noite fechou miúda. Não dá pra saber o que vem.",
		"Nada avisa nada. É só o silêncio e o pavio queimando.",
		"A noite está quieta de um jeito que não quer dizer coisa boa.",
	]
	return omens[randi() % omens.size()]
