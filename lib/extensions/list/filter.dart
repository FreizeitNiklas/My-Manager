extension Filter<T> on Stream <List<T>> { //alle Strems mit Listen vom typ "T" werden um "Filter" erweitert
  Stream<List<T>> filter(bool Function(T) where) =>
  //"filter" wird zur "Stream" Klasse hinzugefügt
  //Definition von "filter": nutzt "where" als Parameter | akzeptiert nur Argumente vom Typ "T" und gibt ein "bool" zurück -> Diese Funktion dient als Filterkriterium
      map ((items) => items.where(where).toList());
  //"map" wird auf den Stream angewendet -> ordnet so die Werte des Streams
  //Anwendung auf den Stream passiert über "items". "items" ist die Liste "T"-Elemente, die aus dem Stream kommen
  //"i.w(w)" filter die Liste "items" nach der "where" Funktion und gibt nur zurück was die "where" Kriterien erfüllt
  //"tL()" übergibt das Ergebnis an eine Liste
  //Das Ergebnis von "map" ist ein neuer Stream, dessen Elemente gefilterte Listen sind.
}