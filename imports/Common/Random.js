.pragma library

//Erzeugt eine Zufallszahl zwischen 0 (inklusive) und 1 (exklusive)
function getRandom() {
    return Math.random();
}

//Erzeugt eine Zufallszahl zwischen zwei Zahlen
//Das Beispiel gibt eine zufällige Zahl zwischen zwei Zahlen zurück. Der Rückgabewert is größer oder gleich min und kleiner als max.
function getRandomArbitrary(min, max) {
  return Math.random() * (max - min) + min;
}

function getRandomInt(max) {
    return Math.floor(Math.random() * max);
}

//Erzeugt eine ganze Zufallszahl zwischen zwei Zahlen
//Das Beispiel gibt eine zufällige ganze Zahl zwischen den spezifizierten Werten zurück. Der Wert ist nicht kleiner als min (oder der nächstgrößeren ganzen Zahl von min, wenn min keine ganze Zahl ist) und ist kleiner als  (aber nicht gleich) max.
function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min)) + min;
}

//Es könnte verlockend sein, Math.round() zu verwenden, um das Ergebnis zu erreichen, aber das würde dazu führen, dass die zufälligen Zahlen einer ungleichmäßigen Verteilung folgen würden, die möglicherweise nicht den geforderten Bedürfnisse entsprechen würde.
//Erzeugt eine ganze Zufallszahl zwischen zwei Zahlen (inklusiv)
//Die obere getRandomInt() Funktion hat ein inklusives Minimum und ein exklusives Maximum. Was ist, wenn sowohl das Minimum als auch das Maximum inklusive sein sollen? Die getRandomIntInclusive() Funktion ermöglicht dieses:
function getRandomIntInclusive(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min +1)) + min;
}

