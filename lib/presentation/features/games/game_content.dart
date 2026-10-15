/// Content banks for the Practice minigames. Each play draws a random
/// subset, so replays differ. Source: docs "MINIJUEGOS.md" (Voxlab content).
library;

// ── Cazamuletillas ──────────────────────────────────────────────────────

/// Words between `*` are fillers. Level 2 sentences include traps: the same
/// words used with a real meaning ("este libro", "un tipo de música").
const fillerSentencesL1 = [
  '*Eh* hoy les quiero contar *este* algo que me pasó',
  'Fue *o_sea* la mejor decisión de mi vida',
  '*Bueno* la idea es que *tipo* todos participen',
  'Practicar todos los días *¿no?* cambia todo',
  '*Este* el primer punto es *eh* la respiración',
  'Me puse nervioso *o_sea* pero seguí hablando',
  '*Tipo* imaginen que están en un escenario',
  'La pausa *eh* es tu mejor aliada',
  '*Bueno* *este* para cerrar quiero decir algo',
  'Respirá profundo *¿viste?* y empezá de nuevo',
  'El público *tipo* nota menos de lo que creés',
  'Mi charla *o_sea* tiene tres partes',
];

const fillerSentencesL2 = [
  'Fue un buen día y *bueno* lo aprovechamos',
  'Este libro me cambió la vida',
  '*Eh* ¿quién tiene un tipo de música favorito?',
  '*Tipo* que *este* no sabía qué decir',
  'Ese tipo de charla me encanta *¿no?*',
  '*Bueno* el resultado fue bueno',
  'Este año *eh* quiero hablar mejor',
];

// ── Pausa perfecta ──────────────────────────────────────────────────────

/// `||` is a 2-second pause, `|` a 1-second one.
const pauseTexts = [
  '¿Saben cuál es el error más común al hablar en público? || Hablar '
      'rápido. | Hoy les muestro cómo frenar.',
  'Me temblaban las piernas. | El público me miraba. || Y entonces respiré.',
  'Tres cosas cambian una charla. | La voz. | El cuerpo. | Y el mensaje.',
  'Si te tuvieras que quedar con una sola idea, || que sea esta: | '
      'practicá todos los días.',
  '¿Quién de ustedes sintió nervios alguna vez? || Exacto. | Todos.',
  'No necesitás ser perfecto. || Necesitás ser claro.',
];

// ── Cambiá el sentido ───────────────────────────────────────────────────

class EmphasisRound {
  const EmphasisRound(this.sentence, this.meaning, this.answer);

  final String sentence;
  final String meaning;

  /// Index of the word to stress.
  final int answer;
}

const emphasisRounds = [
  EmphasisRound('Yo no dije que fuera fácil', 'Lo dijo otra persona', 0),
  EmphasisRound(
    'Yo no dije que fuera fácil',
    'Lo di a entender, pero no lo dije',
    2,
  ),
  EmphasisRound('Yo no dije que fuera fácil', 'Dije que era otra cosa', 5),
  EmphasisRound('Hoy vamos a practicar juntos', 'No mañana: hoy', 0),
  EmphasisRound('Hoy vamos a practicar juntos', 'No solo a mirar', 3),
  EmphasisRound('Hoy vamos a practicar juntos', 'Nadie se queda afuera', 4),
  EmphasisRound('Esta charla es para vos', 'No para otra persona', 4),
  EmphasisRound('Esta charla es para vos', 'Esta, no la de ayer', 0),
  EmphasisRound('Nunca te rindas antes de intentarlo', 'Ni una sola vez', 0),
  EmphasisRound(
    'Nunca te rindas antes de intentarlo',
    'Después sí podés evaluarlo',
    3,
  ),
  EmphasisRound('Vos podés hablar mejor', 'Sí, se puede lograr', 1),
  EmphasisRound('Vos podés hablar mejor', 'Vos, no solo los demás', 0),
];

// ── Hasta la última fila ────────────────────────────────────────────────

class VolumeRound {
  const VolumeRound(this.phrase, this.targetRow);

  final String phrase;

  /// 1 (front row, soft) to 5 (back row, projected).
  final int targetRow;
}

const volumeRounds = [
  VolumeRound('Bienvenidos a todos, gracias por venir.', 2),
  VolumeRound('Hoy les voy a contar algo importante.', 4),
  VolumeRound('¿Me escuchan bien los del fondo?', 5),
  VolumeRound('Esto cambió mi forma de hablar.', 3),
  VolumeRound('Y entonces, muy despacio, abrí la puerta.', 1),
  VolumeRound('¡Nos vemos en la próxima práctica!', 5),
];

// ── Trabalenguas turbo ──────────────────────────────────────────────────

class TongueTwister {
  const TongueTwister(this.text, this.level, this.limits);

  final String text;
  final int level;

  /// Seconds allowed per gear: slow, normal, turbo.
  final List<double> limits;
}

const tongueTwisters = [
  TongueTwister('Pablito clavó un clavito, ¿qué clavito clavó Pablito?', 1, [
    8,
    5,
    3.5,
  ]),
  TongueTwister('Tres tristes tigres tragaban trigo en un trigal.', 1, [
    8,
    5,
    3.5,
  ]),
  TongueTwister('Pepe Pecas pica papas con un pico.', 1, [7, 4.5, 3]),
  TongueTwister(
    'El cielo está enladrillado, ¿quién lo desenladrillará? El '
    'desenladrillador que lo desenladrille buen desenladrillador será.',
    2,
    [14, 10, 7],
  ),
  TongueTwister(
    'Erre con erre cigarro, erre con erre barril, rápido corren los carros '
    'cargados de azúcar del ferrocarril.',
    2,
    [14, 10, 7],
  ),
  TongueTwister(
    'Compré pocas copas, pocas copas compré, y como compré pocas copas, '
    'pocas copas pagué.',
    3,
    [12, 8, 6],
  ),
  TongueTwister(
    'Me han dicho que has dicho un dicho que han dicho que he dicho yo.',
    3,
    [10, 7, 5],
  ),
];

// ── Swipe decks ─────────────────────────────────────────────────────────

class SwipeCard {
  const SwipeCard(this.text, this.isGood, this.why, {this.emoji = ''});

  final String text;

  /// Right swipe (good) or left swipe (bad).
  final bool isGood;
  final String why;
  final String emoji;
}

const bodyCards = [
  SwipeCard(
    'Pies separados al ancho de los hombros, mirada al frente',
    true,
    'Postura de anclaje: transmite estabilidad.',
    emoji: '🧍',
  ),
  SwipeCard(
    'Brazos cruzados sobre el pecho',
    false,
    'Se lee como cierre o defensa.',
    emoji: '🙅',
  ),
  SwipeCard(
    'Palmas abiertas a la altura de la cintura',
    true,
    'Transmite honestidad y apertura.',
    emoji: '👐',
  ),
  SwipeCard(
    'Manos en los bolsillos',
    false,
    'Esconde las manos y resta presencia.',
    emoji: '🫥',
  ),
  SwipeCard(
    'Balanceándose de un pie al otro',
    false,
    'Delata nervios y distrae.',
    emoji: '🔁',
  ),
  SwipeCard(
    'Mostrar tres dedos al decir "tres razones"',
    true,
    'Un gesto que ilustra lo que decís.',
    emoji: '🤟',
  ),
  SwipeCard(
    'Mirar al piso mientras habla',
    false,
    'Rompe la conexión con el público.',
    emoji: '👇',
  ),
  SwipeCard(
    'Sonreír al empezar',
    true,
    'Genera un clima cercano.',
    emoji: '😊',
  ),
  SwipeCard(
    'Señalar con el dedo al público',
    false,
    'Puede sentirse como un reto.',
    emoji: '👉',
  ),
  SwipeCard(
    'Gestos entre la cintura y los hombros',
    true,
    'Es la zona natural de los gestos.',
    emoji: '🙌',
  ),
  SwipeCard(
    'Tocarse la cara o el pelo todo el tiempo',
    false,
    'Gesto de autocalma: transmite inseguridad.',
    emoji: '🤦',
  ),
  SwipeCard(
    'Caminar hacia otro punto al cambiar de idea',
    true,
    'Movimiento con propósito: ordena el discurso.',
    emoji: '🚶',
  ),
  SwipeCard(
    'Mirar a la cámara en una videollamada',
    true,
    'Es el contacto visual digital.',
    emoji: '📹',
  ),
  SwipeCard(
    'Agarrarse con fuerza del atril',
    false,
    'Transmite tensión y rigidez.',
    emoji: '✊',
  ),
];

const hookOpenings = [
  SwipeCard(
    '"¿Cuándo fue la última vez que dijiste que no?"',
    true,
    'Una pregunta que hace pensar engancha enseguida.',
  ),
  SwipeCard(
    '"Bueno, eh, hoy les voy a hablar de la comunicación."',
    false,
    'Desperdicia los primeros segundos.',
  ),
  SwipeCard(
    '"Imaginá que mañana te despertás sin poder hablar."',
    true,
    'Una imagen que el público puede ver.',
  ),
  SwipeCard(
    '"Perdón, no preparé mucho, así que vamos rápido."',
    false,
    'Pedir perdón al inicio baja las expectativas.',
  ),
  SwipeCard(
    '"El primer día que subí a un escenario, me temblaban las piernas."',
    true,
    'Una historia breve genera curiosidad.',
  ),
  SwipeCard(
    '"Primero quiero agradecer a todos los presentes, a los '
        'organizadores, a…"',
    false,
    'Los agradecimientos largos van después del gancho.',
  ),
  SwipeCard(
    '"¿Quién de ustedes durmió ocho horas anoche?"',
    true,
    'Involucra al público desde el primer segundo.',
  ),
  SwipeCard(
    '"El tema de hoy es bastante aburrido, pero bueno."',
    false,
    'Si vos no le das valor, el público tampoco.',
  ),
  SwipeCard(
    '"Hace un año casi abandono todo. Hoy les cuento por qué no lo hice."',
    true,
    'Promete una historia con conflicto.',
  ),
  SwipeCard(
    '"Les voy a leer las diapositivas."',
    false,
    'Leer diapositivas desconecta al público.',
  ),
];

const hookClosings = [
  SwipeCard(
    '"Esta semana, probá hablar un minuto por día frente al espejo."',
    true,
    'Un llamado a la acción concreto y posible.',
  ),
  SwipeCard(
    '"Y bueno, eso es todo, creo."',
    false,
    'Un cierre flojo apaga la charla.',
  ),
  SwipeCard(
    '"¿Se acuerdan de la pregunta del inicio? Ahora ya saben la respuesta."',
    true,
    'Cierre circular: retoma la apertura.',
  ),
  SwipeCard(
    '"Se me acabó el tiempo, así que hasta acá llego."',
    false,
    'Suena a que no hubo plan.',
  ),
  SwipeCard(
    '"Si se llevan una sola idea, que sea esta: la práctica vence al '
        'miedo."',
    true,
    'Resume la idea central.',
  ),
  SwipeCard(
    '"No sé si se entendió, pero bueno, gracias."',
    false,
    'Le resta valor a todo lo que dijiste.',
  ),
];

// ── Armá el discurso ────────────────────────────────────────────────────

class SpeechPuzzle {
  const SpeechPuzzle({
    required this.title,
    required this.slots,
    required this.blocks,
    this.intruder,
  });

  final String title;

  /// Slot labels, in order.
  final List<String> slots;

  /// Blocks in the correct order.
  final List<String> blocks;

  /// A block that does not belong (level 3).
  final String? intruder;
}

const speechPuzzles = [
  SpeechPuzzle(
    title: 'Dormir bien',
    slots: ['Gancho', 'Idea 1', 'Idea 2', 'Idea 3', 'Cierre'],
    blocks: [
      '¿Quién durmió ocho horas anoche?',
      'Dormir mejora la memoria.',
      'También regula el humor.',
      'Y te da energía para todo el día.',
      'Esta noche, apagá el celular media hora antes.',
    ],
  ),
  SpeechPuzzle(
    title: 'Leer',
    slots: ['Gancho', 'Idea 1', 'Idea 2', 'Idea 3', 'Cierre'],
    blocks: [
      '¿Cuál fue el último libro que te atrapó?',
      'Leer amplía tu vocabulario.',
      'Te ayuda a concentrarte.',
      'Y te hace mejor conversador.',
      'Empezá hoy con diez páginas.',
    ],
  ),
  SpeechPuzzle(
    title: 'PREP: caminar',
    slots: ['Punto', 'Razón', 'Ejemplo', 'Punto'],
    blocks: [
      'Caminar a diario es el mejor hábito.',
      'Porque despeja la cabeza.',
      'Cuando camino veinte minutos, vuelvo con ideas nuevas.',
      'Por eso, caminar es mi hábito número uno.',
    ],
  ),
  SpeechPuzzle(
    title: 'PREP: ensayar',
    slots: ['Punto', 'Razón', 'Ejemplo', 'Punto'],
    blocks: [
      'Practicar en voz alta es clave.',
      'Porque entrenás la voz y el cuerpo a la vez.',
      'Cuando me grabé, descubrí que decía "eh" todo el tiempo.',
      'Así que ensayá siempre en voz alta.',
    ],
    intruder: 'Bueno, eh, no sé qué más decir.',
  ),
  SpeechPuzzle(
    title: 'Hacer deporte',
    slots: ['Gancho', 'Idea 1', 'Idea 2', 'Idea 3', 'Cierre'],
    blocks: [
      'Imaginá terminar el día con más energía que al empezar.',
      'El deporte mejora tu salud.',
      'Te ayuda a manejar el estrés.',
      'Y te conecta con otras personas.',
      'Mañana, sumá quince minutos de movimiento.',
    ],
    intruder: 'Perdón, me olvidé lo que iba a decir.',
  ),
];

// ── Palabra prohibida ───────────────────────────────────────────────────

class TabooRound {
  const TabooRound({
    required this.target,
    required this.banned,
    required this.correct,
    required this.wrong,
  });

  final String target;
  final List<String> banned;
  final String correct;

  /// Two descriptions that use a banned word and one that is unclear.
  final List<String> wrong;
}

const tabooRounds = [
  TabooRound(
    target: 'Micrófono',
    banned: ['voz', 'sonido', 'hablar'],
    correct:
        'Aparato que se sostiene cerca de la boca para que todo un '
        'salón te escuche.',
    wrong: [
      'Sirve para que tu voz llegue más lejos.',
      'Capta el sonido cuando alguien está en un escenario.',
      'Es algo que hay en los escenarios.',
    ],
  ),
  TabooRound(
    target: 'Aplauso',
    banned: ['manos', 'público', 'ruido'],
    correct:
        'Lo que te regalan al final de una buena charla para '
        'felicitarte.',
    wrong: [
      'Juntar las manos varias veces muy rápido.',
      'Lo que hace el público cuando le gusta algo.',
      'Algo que pasa a veces.',
    ],
  ),
  TabooRound(
    target: 'Nervios',
    banned: ['miedo', 'ansiedad', 'temblar'],
    correct:
        'Esa sensación en la panza y el corazón acelerado antes de un '
        'desafío importante.',
    wrong: [
      'El miedo que sentís antes de salir a escena.',
      'Cuando te empiezan a temblar las piernas.',
      'Lo que tienen las personas.',
    ],
  ),
  TabooRound(
    target: 'Escenario',
    banned: ['teatro', 'subir', 'actuar'],
    correct:
        'El lugar elevado frente al público donde se para quien da '
        'la charla.',
    wrong: [
      'La parte del teatro donde están los artistas.',
      'Adonde tenés que subir para presentarte.',
      'Un espacio de un edificio.',
    ],
  ),
  TabooRound(
    target: 'Pausa',
    banned: ['silencio', 'parar', 'esperar'],
    correct:
        'Ese momento breve en que dejás de decir palabras para que una '
        'idea se asiente.',
    wrong: [
      'Un silencio corto entre dos frases.',
      'Cuando tenés que parar un momento.',
      'Algo que hacen algunas personas.',
    ],
  ),
  TabooRound(
    target: 'Discurso',
    banned: ['hablar', 'público', 'palabras'],
    correct:
        'Mensaje preparado que alguien presenta ante un grupo de '
        'personas, con inicio, desarrollo y cierre.',
    wrong: [
      'Cuando tenés que hablar mucho tiempo seguido.',
      'Lo que escucha el público en un acto.',
      'Una cosa que se dice.',
    ],
  ),
  TabooRound(
    target: 'Muletilla',
    banned: ['eh', 'palabra', 'repetir'],
    correct:
        'Ese relleno que se te escapa cuando no sabés cómo seguir la '
        'frase, como "este" u "o sea".',
    wrong: [
      'Es como cuando decís "eh" todo el tiempo.',
      'Una palabra que se usa mucho.',
      'Algo que no está bien.',
    ],
  ),
  TabooRound(
    target: 'Espejo',
    banned: ['reflejo', 'mirar', 'vidrio'],
    correct: 'Objeto del baño frente al que podés ensayar y ver tus gestos.',
    wrong: [
      'Te devuelve tu reflejo.',
      'Un vidrio especial para mirarte.',
      'Algo que está en una pared.',
    ],
  ),
  TabooRound(
    target: 'Respirar',
    banned: ['aire', 'pulmones', 'nariz'],
    correct:
        'Lo que hacés sin pensar todo el día y que, si lo hacés lento, '
        'te calma.',
    wrong: [
      'Meter aire y sacarlo.',
      'Lo que hacen tus pulmones.',
      'Una acción del cuerpo.',
    ],
  ),
  TabooRound(
    target: 'Sonrisa',
    banned: ['boca', 'feliz', 'dientes'],
    correct:
        'El gesto de la cara que hacés al empezar una charla para '
        'generar un clima cercano.',
    wrong: [
      'Cuando estirás la boca hacia los costados.',
      'La cara que ponés cuando estás feliz.',
      'Una expresión.',
    ],
  ),
];

// ── Historia en 3 cartas ────────────────────────────────────────────────

const storyCharacters = [
  'Una profesora de música',
  'Un perro que habla',
  'Una abuela inventora',
  'Un robot tímido',
  'Un niño detective',
  'Una chef famosa',
  'Un gato astronauta',
  'Una estudiante nueva',
];

const storyPlaces = [
  'Una estación de tren',
  'Una isla desierta',
  'Un supermercado',
  'La luna',
  'Un barco pirata',
  'Una biblioteca',
  'Un ascensor trabado',
  'Un concurso de talentos',
];

const storyProblems = [
  'Se corta la luz',
  'Perdió algo muy valioso',
  'Llega tarde a algo importante',
  'Tiene que hablar en público',
  'Nadie le cree',
  'Olvidó todas las palabras',
  'Tiene que tomar una decisión difícil',
  'Se equivocó de puerta',
];

// ── Ruleta de improvisación ─────────────────────────────────────────────

class ImprovStructure {
  const ImprovStructure(this.name, this.steps);

  final String name;
  final String steps;
}

const improvStructures = [
  ImprovStructure('PREP', 'Punto → Razón → Ejemplo → Punto'),
  ImprovStructure('Pasado, presente y futuro', 'Antes → Ahora → Después'),
  ImprovStructure('Problema y solución', 'Problema → Solución → Beneficio'),
  ImprovStructure('Tres razones', 'Idea → Razón 1, 2 y 3 → Cierre'),
  ImprovStructure('Historia', 'Situación → Conflicto → Resolución'),
];

const improvTopics = [
  'Mi desayuno ideal',
  'Si pudiera tener un superpoder',
  'El mejor consejo que recibí',
  'Por qué todos deberían aprender a cocinar',
  'Mi canción para un día difícil',
  'Cómo sería la escuela perfecta',
  'Un invento que haría falta',
  'El lugar donde me gustaría vivir',
  'Qué haría con un día libre',
  'Por qué vale la pena aprender otro idioma',
  'La tecnología que más me ayuda',
  'Un hábito que quiero empezar',
  'Mi deporte o juego favorito',
  'Qué le diría a mi yo de hace cinco años',
  'Por qué los animales nos hacen bien',
  'Las vacaciones perfectas',
  'Lo mejor de mi ciudad',
  'Una película o serie que recomendaría',
  'Cómo convencería a alguien de leer más',
  'Si fuera presidente por un día',
];

// ── Mito o realidad ─────────────────────────────────────────────────────

class MythFact {
  const MythFact(this.statement, this.isFact, this.why);

  final String statement;
  final bool isFact;
  final String why;
}

const mythFacts = [
  MythFact(
    'El público nota todos tus nervios.',
    false,
    'Se notan mucho menos de lo que creés (ilusión de transparencia).',
  ),
  MythFact(
    'Sentir nervios es normal, incluso con experiencia.',
    true,
    'Es una reacción natural del cuerpo ante un desafío.',
  ),
  MythFact(
    'Si te trabás, tenés que empezar de nuevo.',
    false,
    'Hacé una pausa, respirá y seguí.',
  ),
  MythFact(
    'Exhalar lento ayuda a calmarte.',
    true,
    'Le indica a tu cuerpo que no hay peligro.',
  ),
  MythFact(
    'Memorizar palabra por palabra es lo más seguro.',
    false,
    'Es mejor memorizar el orden de las ideas.',
  ),
  MythFact(
    'Ensayar en voz alta es mejor que leer en silencio.',
    true,
    'Entrenás voz, respiración y cuerpo a la vez.',
  ),
  MythFact(
    'Los buenos oradores nacen así.',
    false,
    'Hablar en público es una habilidad que se entrena.',
  ),
  MythFact(
    'Tener agua cerca ayuda con la boca seca.',
    true,
    'Un truco simple y efectivo.',
  ),
  MythFact(
    'Pedir perdón por estar nervioso mejora la charla.',
    false,
    'Llama la atención sobre algo que casi nadie notaba.',
  ),
  MythFact(
    'Decirte "estoy con ganas" puede ayudarte.',
    true,
    'Reencuadra los nervios como entusiasmo.',
  ),
  MythFact(
    'Hay que eliminar los nervios por completo.',
    false,
    'Un poco de tensión te mantiene atento y con energía.',
  ),
  MythFact(
    'Preparar bien la primera frase reduce los nervios.',
    true,
    'Los primeros segundos son los que más cuestan.',
  ),
];
