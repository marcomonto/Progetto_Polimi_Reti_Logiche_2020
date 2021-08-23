# Progetto_Polimi_Reti_Logiche_2020
# Progetto Reti Logiche 2019/2020

## Redattore: Marco Montorsi

# Introduzione

## 1.1 Specifiche Di Progetto

La specifica della Prova finale (Progetto di Reti Logiche) 2019 è ispirata al metodo di codifica a bassa dissipazione di potenza denominato &quot;Working Zone&quot;.
 Il metodo di codifica Working Zone è un metodo pensato per il Bus Indirizzi che si usa per trasformare il valore di un indirizzo quando questo viene trasmesso, se appartiene a certi intervalli (detti appunto working-zone).

La working-zone è un intervallo di indirizzi di dimensione fissa (Dwz) che parte da un indirizzo base. All&#39;interno dello schema di codifica possono esistere multiple working-zone (Nwz). Lo schema modificato di codifica da implementare è il seguente:

Quando l&#39;indirizzo da trasmettere (ADDR) non appartiene a nessuna Working Zone, viene trasmesso così come è, e un bit addizionale rispetto ai bit di indirizzamento (WZ\_BIT) viene messo a 0. In pratica dato ADDR, verrà trasmesso WZ\_BIT=0 concatenato ad ADDR (WZ\_BIT &amp; ADDR, dove &amp; è il simbolo di concatenazione

Quando l&#39;indirizzo da trasmettere (ADDR) appartiene ad una Working Zone, il bit addizionale WZ\_BIT assume il valore pari a 1, mentre i bit di indirizzo vengono divisi in 2 sotto campi rappresentanti: Il numero binario della working-zone al quale l&#39;indirizzo appartiene (WZ\_NUM), e L&#39;offset rispetto all&#39;indirizzo di base della working zone (WZ\_OFFSET), codificato come one-hot .

Nella versione da implementare il numero di bit per la codifica è pari a 7. Gli indirizzi validi vanno da 0 a 127. Il numero di working-zone è 8 (Nwz=8) mentre la dimensione della working-zone è 4 indirizzi incluso quello base (Dwz=4), vedi **Tab.1**.

| WZ\_OFFSET | 0 | 0001 |
| --- | --- | --- |
| WZ\_OFFSET | 1 | 0010 |
| WZ\_OFFSET | 2 | 0100 |
| WZ\_OFFSET | 3 | 1000 |

**Tab.1 Codifica One-Hot**

Ne deriva che l&#39;indirizzo codificato sarà composto da 8 bit: 1 bit per WZ\_BIT + 7 bit per ADDR, oppure 1 bit per WZ\_BIT, 3 bit per codificare in binario a quale tra le 8 working zone l&#39;indirizzo appartiene, e 4 bit per codificare one hot il valore dell&#39;offset di ADDR rispetto all&#39;indirizzo base.

## 1.2 Interfaccia Del Componente

Il componente da descrivere deve avere la seguente interfaccia.

entity project\_reti\_logiche is port

( i\_clk : in std\_logic;
 i\_start : in std\_logic;
 i\_rst : in std\_logic;
 i\_data : in std\_logic\_vector(7 downto 0);
 o\_address : out std\_logic\_vector(15 downto 0);
 o\_done : out std\_logic;
 o\_en : out std\_logic;
 o\_we : out std\_logic;
 o\_data : out std\_logic\_vector (7 downto 0) );
 end project\_reti\_logiche;

In Particolare:
 • i\_clk è il segnale di CLOCK in ingresso generato dal TestBench

• i\_start è il segnale di START generato dal Test Bench

• i\_rst è il segnale di RESET che inizializza la macchina pronta per ricevere il primo segnale di START

• i\_data è il segnale (vettore) che arriva dalla memoria in seguito ad una richiesta di lettura

• o\_address è il segnale (vettore) di uscita che manda l&#39;indirizzo alla memoria;

• o\_done è il segnale di uscita che comunica la fine dell&#39;elaborazione e il dato di uscita scritto in memoria

• o\_en è il segnale di ENABLE da dover mandare alla memoria per poter comunicare (sia in lettura che in scrittura)

• o\_we è il segnale di WRITE ENABLE da dover mandare alla memoria (=1) per poter scriverci. Per leggere da memoria esso deve essere 0

• o\_data è il segnale (vettore) di uscita dal componente verso la memoria.

L&#39;interfaccia del componente dovrà comunicare con la RAM per chiedere in lettura i valori delle WZ e infine per chiedere la scrittura del risultato, per questo progetto vi sono a disposizione 10 indirizzi, così suddivisi nella **Tab.2** :

| **Indirizzo 0** | **Valore 1° WZ** |
| --- | --- |
| **Indirizzo 1** | **Valore 2° WZ** |
| **Indirizzo 2** | **Valore 3° WZ** |
| **Indirizzo 3** | **Valore 4° WZ** |
| **Indirizzo 4** | **Valore 5° WZ** |
| **Indirizzo 5** | **Valore 6° WZ** |
| **Indirizzo 6** | **Valore 7° WZ** |
| **Indirizzo 7** | **Valore 8° WZ** |
| **Indirizzo 8** | **Valore Indirizzo Da Codificare** |
| **Indirizzo 9** | **Valore Indirizzo Codificato** |

**Tab.2 Suddivisione indirizzi RAM**

**Note Finali Su Specifica** :

- Si consideri che gli indirizzi base delle working-zone non cambieranno mai all&#39;interno della stessa esecuzione, inoltre le working-zone non possono sovrapporsi
- Il modulo partirà nella elaborazione quando un segnale START in ingresso verrà portato a 1. Il segnale di START rimarrà alto fino a che il segnale di DONE non verrà portato alto; Al termine della computazione (e una volta scritto il risultato in memoria), il modulo da progettare deve alzare (portare a 1) il segnale DONE che notifica la fine dell&#39;elaborazione. Il segnale DONE deve rimanere alto fino a che il segnale di START non è riportato a 0. Un nuovo segnale start non può essere dato fin tanto che DONE non è stato riportato a zero. Se a questo punto viene rialzato il segnale di START, il modulo dovrà ripartire con la fase di codifica.
- Il software di sviluppo utilizzato è Vivado e il linguaggio del codice è il VHDL.

1.
# Scelte Progettuali

## **Scelta Design**

- Inizialmente è stato elaborato un primo semplice algoritmo, con lo scopo di visualizzare le fasi del componente:

- Per implementare questo algoritmo si utilizza una Macchina a Stati Finiti (FSM), con la quale si costruiscono gli stati della macchina, aggiungendone diversi per un corretto funzionamento e per una corretta comunicazione con la RAM.

**Per una lettura più comprensibile è stato omesso da ogni stato la scelta di i\_rst, perché nel caso in cui durante l&#39;esecuzione, i\_rst venga portato a 1, la macchina tornerà in START**

## Descrizione Stati

- START : Stato iniziale della macchina dove inizializza le variabili utilizzate e aspetta fino a quando il segnale i\_start diventi 1, una volta letto, procede verso ADDR\_READ\_ASK
- ADDR\_READ\_ASK : In questo stato la FSM chiede alla RAM il valore da codificare all&#39;indirizzo 8, e poi procede verso ADDR\_READ\_WAIT
- ADDR\_READ\_WAIT : In questo stato la FSM non fa altro che aspettare per un ciclo di clock la risposta della RAM e procede verso ADDR\_READ\_GET
- ADDR\_READ\_GET : In questo stato la FSM salva il valore dell&#39;indirizzo da codificare e procede verso CHECK\_ADDR
- CHECK\_ADDR : In questo stato la FSM controllerà quante WZ ha controllato grazie a una variabile intera count, se dovrà controllare ancora andrà in READ\_MEM\_ASK, altrimenti si porterà in DONE settando il parametro booleano &quot;found\_dwz&quot;
- READ\_MEM\_ASK : In questo stato la FSM richiede l&#39;indirizzo della prossima WZ da controllare alla RAM basandosi sul valore di count, per poi procedere in READ\_MEM\_WAIT
- READ\_MEM\_WAIT : In questo stato la FSM non fa altro che aspettare per un ciclo di clock la risposta della RAM e procede verso READ\_MEM\_GET
- READ\_MEM\_GET : In questo stato la FSM salva il valore della WZ e procede verso VALUE\_SET
- VALUE\_SET : In questo stato la FSM calcola la differenza, salvandola nella variabile difference\_variables, la quale rappresenta la differenza tra l&#39;indirizzo da codificare e della WZ controllata, infine procede verso CHECK\_DWZ
- CHECK\_DWZ : In questo stato la FSM fa un controllo su difference\_variables, nel caso sia negativa sicuramente il valore dell&#39;indirizzo della WZ è maggiore quindi non appartiene alla WZ, e quindi la FSM procede in COUNT\_UPDATE, in caso contrario, quindi se la differenza è positiva, controllo se è minore o uguale di 3, se così allora l&#39;indirizzo appartiene alla WZ e quindi la FSM procede verso DWZ\_FOUND per la codifica dell&#39;indirizzo, se invece la differenza è maggiore di 3 allora l&#39;indirizzo non appartiene alla WZ, quindi si muoverà verso COUNT\_UPDATE
- COUNT\_UPDATE : In questo stato la FSM semplicemente incrementerà count di 1 per poi procedere verso CHECK\_ADDR
- DWZ\_FOUND : In questo stato la FSM codificherà l&#39;indirizzo one hot , appartenente alla WZ settando la variabile booleana found\_dwz a &quot;true&quot;, e infine procederà verso DONE
- DONE : In questo stato la FSM, in base alla variabile found\_dwz, invierà alla RAM l&#39;indirizzo codificato corretto, per poi procedere verso WRITE\_MEM\_RESULT
- WRITE\_MEM\_RESULT : In questo stato la FSM setta o\_done a 1, e aspetta fino a un segnale di i\_start uguale a 0, una volta ricevuto torna a START

  1.
## Analisi Punti Chiave Codice VHDL

1. Per il codice ho utilizzato un unico processo, process(i\_clk,i\_rst), con sensitivity list solo il parametro i\_clk e i\_rst , cosi da attivarsi ogni volta che i\_clk o i\_rst commuta.

1. Per gli stati ho utilizzato una singola variabile di tipo state, chiamata next\_state, alla fine di ogni stato, la FSM, setterà next\_state al prossimo stato, quindi al prossimo clock la macchina entrerà nello stato next\_state correttamente, può non essere immediata la comprensione di questa scelta, ma deriva da una meno recente versione del codice nella quale utilizzavo due variabili per lo stato, una per l&#39;attuale e una per il prossimo, settandole in modo corretto quando il clok era a 0, operazione che poi è risultata intuile perché non comportava alcun beneficio rispetto all&#39;utilizzo di un&#39;unica variabile state.


2. I vari stati verranno gestiti attraverso un case sulla variabile next\_state, dove ogni stato\_x avrà il suo when &quot;STATO\_X&quot; seguito dalle operazione svolte dalla FSM in quello stato.


3. Una parte fondamentale di questo processo è il ruolo che gioca la variabile count, facendola partire da 0 la FSM riesce sempre ad indirizzarsi al corretto indirizzo di una WZ contenuto nella RAM, e quindi poi nel caso riesce a codificare la parte corretta della WZ nel caso l&#39;indirizzo appartenga a tale WZ.

  1.
## Register Transfer Level Schematic

Per una più approfondita lettura del componente appena descritto, allego la RTL schematic, ovviamente l&#39;immagine può risultare difficile da comprendere, ma può aiutare a capire alcuni punti chiave del componente.

3 Risultati Test

3.1 Test Generici

Come primi test ho eseguito quelli proposti da specifica per verificare un primo corretto funzionamento della macchina, dove tutti i test hanno un periodo di clock di 100 ns, riporto i valori della memoria con relativa wave window:

CASO 1 CON VALORE NON PRESENTE IN NESSUNA WORKING-ZONE

| **Indirizzo Memoria** | **Valore** | **Commento** |
| --- | --- | --- |
| 0 | 4 | Indirizzo Base WZ 0 |
| 1 | 13 | Indirizzo Base WZ 1 |
| 2 | 22 | Indirizzo Base WZ 2 |
| 3 | 31 | Indirizzo Base WZ 3 |
| 4 | 37 | Indirizzo Base WZ 4 |
| 5 | 45 | Indirizzo Base WZ 5 |
| 6 | 77 | Indirizzo Base WZ 6 |
| 7 | 91 | Indirizzo Base WZ 7 |
| 8 | 42 | ADDR da codificare |
| 9 | 42 | Valore codificato in OUTPUT |

WAVE WINDOW

Come si può notare la macchina prima chiede l&#39;indirizzo 8 alla RAM, poi controlla i valori delle WZ e infine non trovando nessuna corrispondenza, scrive nell&#39;indirizzo 9 il valore 2a, che in decimale corrisponde a 42 come da consegna, il tutto in circa 7 us.

CASO 2 CON VALORE PRESENTE IN UNA WORKING-ZONE

| **Indirizzo Memoria** | **Valore** | **Commento** |
| --- | --- | --- |
| 0 | 4 | Indirizzo Base WZ 0 |
| 1 | 13 | Indirizzo Base WZ 1 |
| 2 | 22 | Indirizzo Base WZ 2 |
| 3 | 31 | Indirizzo Base WZ 3 |
| 4 | 37 | Indirizzo Base WZ 4 |
| 5 | 45 | Indirizzo Base WZ 5 |
| 6 | 77 | Indirizzo Base WZ 6 |
| 7 | 91 | Indirizzo Base WZ 7 |
| 8 | 33 | ADDR da codificare |
| 9 | 180 | Valore codificato in OUTPUT |

WAVE WINDOW

Come si può notare la macchina trova la WZ all&#39;indirizzo 3 e scrive in memoria all&#39;indirizzo 9 b4, ovvero 180, poiché l&#39;indirizzo codificato risulta 1(WZ found) – 011(terzo indirizzo WZ) – 0100(one-hot corrispondente), il processo impiega circa 4 us.

3.2 Test casi critici

Un primo caso particolare è l&#39;attivazione del segnale di reset durante la computazione, come esempio prendiamo quello relativo all&#39;esempio precedente, ovvero il caso 2, riporto sempre la wave window di tale test:

WAVE WINDOW

La FSM si comporta come l&#39;esempio precedente, quando a 3,5 us, la macchina riceve un segnale di reset, e come da specifica ritorna allo stato iniziale per poi riprendere il processo.

Per testare le tempistiche di processo della macchina, ho deciso di verificare i casi peggiore e migliore per capire l&#39;intervallo temporale di funzionamento, ovviamente senza considerare un possibile segnale di reset, evento che aumenterebbe le tempistiche.

Caso Migliore : l&#39;indirizzo da codificare appartiene alla prima WZ, cosi la macchina codificherà al primo ciclo l&#39;indirizzo e terminerà la computazione, tutto questo con tempistiche di circa 1,8 us, sempre con periodo di clock di 100 ns.

Caso Peggiore : l&#39;indirizzo da codificare non appartiene a nessuna WZ, in questo caso la macchina dovrà leggere tutti gli otto valori in memoria prima di poter codificare l&#39;indirizzo, questo con tempo di esecuzione di circa 6,8 us, sempre con periodo di clock di 100 ns, risultato uguale al test del caso 1 trattato infatti.

Dati i due esempi si evince che l&#39;intervallo di esecuzione, con periodo di clock di 100 ns, si posiziona tra 2 us e 7 us, in cifra arrotondata; tutti i test vengono superati correttamente in _Behavorial_, _Post-Synthesis functional_ e _Post Synthesis timing_ simulation.

  1. Ottimizzazioni

Una possibile modifica per maggiore efficienza sarebbe quella di terminare il controllo delle WZ una volta che i valori letti dalla RAM diventano maggiori dell&#39;indirizzo da codificare, ma questa modifica si potrebbe attuare solo nel caso che nella memoria i valori delle WZ siano inserite in maniera crescente, per rendere la FSM più universale ho deciso di non inserire questa modifica, anche se una volta stabilito un possibile protocollo potrebbe rendere molto più efficiente la macchina.
