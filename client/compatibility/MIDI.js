MIDI = {};
MIDI.keyToNote = {}; // C8  == 108
MIDI.noteToKey = {}; // 108 ==  C8
(function () {
  //var A0 = 0x15; // first note
  var C0 = 0x10; // first note
	var C8 = 0x6C; // last note
	var number2key = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"];
	for (var n = C0; n <= C8; n++) {
		var octave = (n - 12) / 12 >> 0;
		var name = number2key[n % 12] + octave;
		MIDI.keyToNote[name] = n;
		MIDI.noteToKey[n] = name;
	}
})();