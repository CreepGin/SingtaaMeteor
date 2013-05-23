class @ScoreMan

  @durations:
    "w": 1
    "h": 2
    "q": 4
    "8": 8
    "16": 16
    "32": 32

  @dn2l:
    "1": "w"
    "2": "h"
    "3": "hd"
    "4": "q"
    "6": "qd"
    "8": "8"
    "12": "8d"
    "16": "16"
    "24": "16d"
    "32": "32"
    "48": "32d"
    "64": "64"
  
  ###
  Transforms the VexTab code into the simpler format
  @param  {string} code The simpler code from MapleTunes
  @return {string} The transformed code
  ###
  @transformCode: (code, tabType) ->
    #comment block
    code = code.replace(/\/\*.*?\*\/\n?/g, "")
    #b's to @'s
    code = code.replace /[A-G]b/gi, (m) ->
      m.replace("b", "@")
    code = code.replace /([ABCDEFG][#@]?[#@]?)+/g, (m) ->
      c = m.replace /([ABCDEFG][#@]?[#@]?)/g, "$1-"
      c.substring 0, c.length-1
    code = code.replace /([ABCDEFG][#@]?[#@]?[0-9]){2,}/g, (m) ->
      c = m.replace /([ABCDEFG][#@]?[#@]?[0-9])/g, "$1."
      c = c.substring 0, c.length-1
      "(" + c + ")"
    code = code.replace /([ABCDEFG][#@]?[#@]?)([0-9])/g, "$1/$2"
    #log code
    staves = code.trim().split(/\n{2,}/g)
    staves = _.map staves, (staff) ->
      lines = staff.split("\n")
      lines = _.map lines, (line) ->
        if _(line).startsWith ">"
          line = "text .2," + _(line).trim(">")
        else
          line = "notes " + line
      staff = _.reduce lines, (memo, line, index) ->
        if (_(line).startsWith "notes") and index isnt 0
          return (memo + " | \n" + line).trim()
        else
          return (memo + "\n" + line).trim()
      , ""
    
    staves = _.map staves, (staff, index) =>
      if tabType is "tab"
        staff = "tabstave notation=true\n" + staff
      else if tabType is "single"
        staff = "tabstave notation=true tablature=false\n" + staff
      else if tabType is "grand"
        staff = "tabstave notation=true tablature=false" + (if index%2 is 1 then " clef=bass" else "") + "\n" + staff

    res = "options width=960 scale=0.75 space=10\n\n"
    res += staves.join("\n\n")
    #log res
    res

  @getTrackFromStaves: (staves, tempo, beat) ->
    track = 
      bpm: tempo
      beat: beat
    notes = staves.reduce (memo, staff) ->
      memo.concat staff.tab_notes
    , []
    noteGroups = []
    for note in notes
      d = note.duration
      if d is "b" #TODO handle special bars in the future
        continue
      noteGroup = 
        duration: ScoreMan.durations[d]
        type: if note.noteType is "n" then "note" else "rest"
        keys: []
      ###
      for key in note.keyProps
        noteGroup.keys.push
          pitch: key.int_value + 12
      ###
      if note.playNote
        for key, i in note.playNote
          noteGroup.keys.push
            pitch: ScoreMan.getPitchFromText key
            fret: parseInt note.positions[i].fret
            str: parseInt note.positions[i].str
      noteGroups.push noteGroup
    track.noteGroups = noteGroups
    track

  @getPitchFromText: (text) ->
    letter = text.charAt(0)
    number = text.slice(-1)
    t = text.charAt(1)
    accidental = if t is "#" then 1 else if t is "b" then -1 else 0
    #pitch = MIDI.keyToNote[letter+number]
    #pitch + accidental
    ScoreMan.getPitchFromKey letter, number, accidental

  @getPitchFromKey: (step, octave, accidental) ->
    pitch = MIDI.keyToNote[step+octave]
    pitch + accidental

  @convertMusicXML: (text) ->
    MEASURE_PER_LINE = 4
    xmlStr = text.replace /<!.+?>/gi, ""
    xmlStr = xmlStr.replace /\n/gi, ""
    xmlStr = xmlStr.replace /> +?</gi, "><"
    json = x2js.xml_str2json xmlStr, "  "
    if json.html
      return ""
    measures = []
    numStaves = 0
    if _.isArray json["score-partwise"].part
      #HACK: merge measures' note arrays
      numStaves = json["score-partwise"].part.length
      s = 1
      measures = _.reduce json["score-partwise"].part, (memo, list) ->
        newMeasure = _.map list.measure, (m) ->
          notesArray = _.map m.note_asArray, (n) ->
            n.staff = s
            n
          m.note_asArray = notesArray
          m
        s++
        if memo.length is 0
          return memo.concat newMeasure
        else
          for me, i in memo
            memo[i].note_asArray = memo[i].note_asArray.concat newMeasure[i].note_asArray
          return memo
      , []
    else
      measures = json["score-partwise"].part.measure
      numStaves = parseInt measures[0].attributes.staves
    if measures.length is 0
      return ""
    log measures
    allLines = []
    for measure, m in measures
      notes = measure.note_asArray.filter (note) ->
        (note.pitch or note.rest) and note.staff
      if notes.length >= 8
        MEASURE_PER_LINE = 3
      if notes.length >= 12
        MEASURE_PER_LINE = 2
      measureNum = m % MEASURE_PER_LINE
      lastDuration = 0
      lastStaff = -1
      lines = []
      for i in [1..numStaves]
        lines.push ""
      for note, n in notes
        type = if note.rest then "rest" else "note"
        duration = 32 / parseInt(note.duration)
        duration = 1 if duration < 1
        s = parseInt(note.staff) - 1
        if s is 1
          log "note:"
          log note
        if duration isnt lastDuration or s isnt lastStaff
          lines[s] += ":"+ScoreMan.dn2l[duration+""]+" "
        if note.pitch
          alter = if note.pitch.alter then parseInt note.pitch.alter else 0
          pitch = @getPitchFromKey note.pitch.step, note.pitch.octave, alter
          if note.chord
            lines[s] = lines[s].trim()
          #if lines[s].slice(-1) is " " and note.tie_asArray and (note.tie_asArray[0] and note.tie_asArray[0]._type is "stop" or note.tie_asArray[1] and note.tie_asArray[1]._type is "stop")
            #lines[s] += "t"
          #log note if not MIDI.noteToKey[pitch]
          lines[s] += MIDI.noteToKey[pitch].replace("b", "b") + " "
          lines[s] = lines[s].replace /t([ABCDEFG][#@]?[#@]?[0-9]){2,}/g, (m) ->
            "t" + m.replace(/t/gi, "")
        else if note.rest
          lines[s] += "## "
        lastDuration = duration
        lastStaff = s
      allLines.push lines
    log "all lines:"
    log allLines
    finalLines = []
    offset = 0
    dividerCount = 0
    for lines, i in allLines
      m = i % MEASURE_PER_LINE
      for line, j in lines
        n = offset + m + j * (MEASURE_PER_LINE + 1)
        finalLines[n] = line
        if m is (MEASURE_PER_LINE - 1)
          finalLines[n+1] = if dividerCount % (12) is (11) then "\n---\n" else ""
          dividerCount++
      if m is (MEASURE_PER_LINE - 1)
        offset += numStaves * (MEASURE_PER_LINE+1)
    finalLines.join "\n"