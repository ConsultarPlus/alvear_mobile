urlDominio(){
  return 'http://calvear-medidores.dynalias.net/';
  // return 'http://10.0.2.2:8000/';
}

urlInspector(){
  return urlDominio() + 'inspecciones/inspectores_json/';
}

urlDescarga(){
  return urlDominio() + 'inspecciones/descarga_json/';
}

urlSincronizar(){
  return urlDominio() + 'inspecciones/sincronizar_json/';
}





