urlDominio(){
  // return 'http://190.193.200.120:1088/';
  // return 'http://192.168.1.32:1088/';
  return 'http://10.0.2.2:8000/';
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





