---
layout: page
title: FOIA
permalink: /foia/
---

### Accesso Civico Generalizzato (FOIA)

Con questa semplice pagina puoi richiedere ufficialmente il dataset dei catasti delle terre bruciate del tuo comune. E' importante perchè in questo modo sensibilizziamo le Pubbliche Amministrazioni ad informare correttamente su quali siano gli incendi avvenuti attorno a noi. Aiutaci a richiedere i dati del tuo comune o di un comune a cui sei interessato! Contiamo su di te!
Seleziona il comune a cui vuoi inviare la richiesta. Verrai ridirezionato al modulo online da compilare con i tuoi dati per l'invio della comunicazione in modo ufficiale.

<form>
<select name="ipa">
<option selected>Seleziona il Comune</option>
{% for member in site.data.ipa %}
<option value="{{member.cf}}">
{{ member.comune }}
</option>
{% endfor %}
</select>
</form>


<a class="foia " target="_blank" id="foia" href="">
<button type="button" class="btn btn-primary">CREA RICHIESTA</button>
</a>

<small>Servizio fornito da <a href="http://www.foiapop.it" target="_blank"> FOIAPop</a></small>

<script src="//code.jquery.com/jquery-1.12.3.js"></script>

<script defer="defer">
$('select').on('change', function() {
  href = 'http://www.foiapop.it/api/accesso-civico-generalizzato?cf=&richiesta=%281%29+La+pubblicazione+dell%E2%80%99elenco+e+delle+relative+perimetrazioni+dei+soprassuoli+gi%C3%A0+percorsi+dal+fuoco+nell%27ultimo+quinquennio+come+previsti+dall%E2%80%99art+10+comma+2+della+Legge+353%2F2000%3B+%282%29+La+relativa+pubblicazione+in+albo+pretorio+comunale+se+non+gi%C3%A0+fatto%3B+%283%29+La+pubblicazione+in+amministrazione+trasparente+nella+sezione+Amministrazione+Trasparente%2FPianificazione+e+Governo+del+Territorio+se+non+gi%C3%A0+fatto+e+dopo+aver+adempiuto+alla+pubblicazione+in+albo+pretorio%2C+se+non+gi%C3%A0+effettuata%2C+ritenendo+l%27adempimento+un+atto+di+governo+del+territorio+di+cui+all%E2%80%99art.+39+comma+1+del+D.+Lgs.+33%2F2012'
  newhref = href.replace('cf=','cf='+ this.value);
$('.foia').attr('href', newhref);
})
</script>