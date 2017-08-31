---
layout: page
title: FOIA
permalink: /foia/
---

## Accesso Civico Generalizzato (FOIA)

Con questa semplice pagina **puoi creare facilmente la richiesta del dataset dei catasti delle terre bruciate del comune di tuo interesse**. <br>
È importante perché, in questo modo, sensibilizziamo le Pubbliche Amministrazioni ad informare correttamente su quali siano gli incendi avvenuti attorno a noi. Ma soprattutto le invitiamo ad applicare esattamente l’art 10 comma 2 della [Legge 353/2000](http://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:legge:2000-11-21;353!vig=) **chiedendo l'elenco con relative perimetrazioni dei soprassuoli già percorsi dal fuoco nell'ultimo quinquennio**. Una legge poco applicata ma molto incisiva quale deterrente alle possibili speculazioni post-incendio, visti i vincoli resi applicabili solo in caso di definizione ed aggiornamento del catasto incendi.<br>
Non ti resta che chiedere! Contiamo su di te!
<br><br>
**Come funziona**
<br>Seleziona il comune per il quale vuoi creare la richiesta, clicca quindi su "*Crea richiesta*". Verrai reindirizzato al modulo online da compilare soltanto con i tuoi dati. Troverai precompilati sia il testo della richiesta sia il destinatario. Andando quindi "*Avanti*"  potrai visionare una anteprima. 
<br>Infine "*Crea Richiesta Foia*" ed ecco il tuo pdf da scaricare. 

**Il successivo invio al Comune**
<br>Potrai inviare la richiesta al Comune in alternativa tramite:
<br>*Trasmissione telematica*: tramite e-mail o PEC all'indirizzo di riferimento della pubblica amministrazione (sottoscrivendo il modulo e allegando una copia del documento di riconoscimento valido oppure apponendo la firma digitale, in questo caso non è necessario allegare copia del documento di riconoscimento);
<br>*Trasmissione analogica*: tramite posta o raccomandata o brevi manu al protocollo della pubblica amministrazione (sottoscrivendo il modulo e allegando una copia del documento di riconoscimento valido).

**Un'ultima cosa**
<br>Se invii una richiesta per il tuo comune - una volta fatto - puoi indicarlo [**qui**](https://docs.google.com/forms/d/e/1FAIpQLSeuzxiMLNOdumO_ln7LqZMeX5BsI632_sceyLJQpu4XrYLdrQ/viewform)? In questo modo altri utenti sapranno se per un dato comune è già stata fatta una richiesta;

Grazie 😉

<br>
<br>

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
  href = 'http://www.foiapop.it/api/accesso-civico-generalizzato?cf=&richiesta=%281%29+La+pubblicazione+dell%E2%80%99elenco+e+delle+relative+perimetrazioni+dei+soprassuoli+gi%C3%A0+percorsi+dal+fuoco+nell%27ultimo+quinquennio+come+previsti+dall%E2%80%99art+10+comma+2+della+Legge+353%2F2000%3B+%282%29+La+relativa+pubblicazione+in+albo+pretorio+comunale+se+non+gi%C3%A0+fatto%3B+%283%29+La+pubblicazione+in+amministrazione+trasparente+nella+sezione+Amministrazione+Trasparente%2FPianificazione+e+Governo+del+Territorio+se+non+gi%C3%A0+fatto+e+dopo+aver+adempiuto+alla+pubblicazione+in+albo+pretorio%2C+se+non+gi%C3%A0+effettuata%2C+ritenendo+l%27adempimento+un+atto+di+governo+del+territorio+di+cui+all%E2%80%99art.+39+comma+1+del+D.+Lgs.+33%2F2013'
  newhref = href.replace('cf=','cf='+ this.value);
$('.foia').attr('href', newhref);
})
</script>
