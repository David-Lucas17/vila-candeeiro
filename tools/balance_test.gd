extends SceneTree

const RUNS := 2000

func _init():
	print("=== A Vigilia do Candeeiro - teste de balanceamento (%d noites por perfil) ===\n" % RUNS)
	report("Chutador (acao aleatoria)", play_many(RUNS, "random"))
	report("Atento (le o pressagio, escuta quando a noite nao avisa)", play_many(RUNS, "smart"))
	report("Beberrao (so toma trago e ora)", play_many(RUNS, "drunk"))
	report("Economico (so pinga azeite)", play_many(RUNS, "oil"))
	quit()

func play_many(runs, profile):
	var stats = {"won": 0, "dark": 0, "fear": 0, "light_left": 0, "fear_left": 0}
	for i in range(runs):
		var v = Vigil.new()
		while not v.is_over():
			v.play(choose(v, profile))
		match v.status:
			Vigil.Status.WON: stats["won"] += 1
			Vigil.Status.LOST_DARK: stats["dark"] += 1
			Vigil.Status.LOST_FEAR: stats["fear"] += 1
		stats["light_left"] += v.light
		stats["fear_left"] += v.fear
	stats["runs"] = runs
	return stats

func choose(v, profile):
	match profile:
		"random":
			var pool = []
			for a in [Vigil.Action.AZEITE, Vigil.Action.SAL, Vigil.Action.REZA, Vigil.Action.TRAGO, Vigil.Action.ESCUTAR]:
				if v.can_play(a):
					pool.append(a)
			return pool[randi() % pool.size()]
		"drunk":
			if v.can_play(Vigil.Action.TRAGO) and v.fear >= 6:
				return Vigil.Action.TRAGO
			return Vigil.Action.REZA
		"oil":
			if v.can_play(Vigil.Action.AZEITE):
				return Vigil.Action.AZEITE
			return Vigil.Action.REZA
		_:
			return smart(v)

func smart(v):

	if v.light <= 2 and v.can_play(Vigil.Action.AZEITE):
		return Vigil.Action.AZEITE
	if v.fear >= 8:
		if v.can_play(Vigil.Action.TRAGO):
			return Vigil.Action.TRAGO
		return Vigil.Action.REZA
	if v.omen_is_vague:
		if v.light <= 4 and v.can_play(Vigil.Action.AZEITE):
			return Vigil.Action.AZEITE
		return Vigil.Action.ESCUTAR
	var want = defense_for(v.current.kind)
	if v.can_play(want):

		if want == Vigil.Action.TRAGO and v.fear <= 3:
			return Vigil.Action.ESCUTAR
		return want
	if v.light <= 4 and v.can_play(Vigil.Action.AZEITE):
		return Vigil.Action.AZEITE
	if v.fear >= 6:
		return Vigil.Action.REZA
	return Vigil.Action.ESCUTAR

func defense_for(kind):
	match kind:
		NightEvent.Kind.SOMBRA:   return Vigil.Action.AZEITE
		NightEvent.Kind.SOLEIRA: return Vigil.Action.SAL
		NightEvent.Kind.ALMA:   return Vigil.Action.REZA
		_:             return Vigil.Action.TRAGO

func report(label, s):
	var pct = func(n): return 100.0 * n / s["runs"]
	print("%s" % label)
	print("    vitoria .......... %5.1f%%" % pct.call(s["won"]))
	print("    morreu no escuro . %5.1f%%" % pct.call(s["dark"]))
	print("    fugiu de medo ..... %5.1f%%" % pct.call(s["fear"]))
	print("    luz media no fim .. %.1f | medo medio no fim .. %.1f\n" % [float(s["light_left"]) / s["runs"], float(s["fear_left"]) / s["runs"]])
