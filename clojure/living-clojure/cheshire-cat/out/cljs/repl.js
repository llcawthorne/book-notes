// Compiled by ClojureScript 1.10.520 {}
goog.provide('cljs.repl');
goog.require('cljs.core');
goog.require('cljs.spec.alpha');
goog.require('goog.string');
goog.require('goog.string.format');
cljs.repl.print_doc = (function cljs$repl$print_doc(p__1456){
var map__1457 = p__1456;
var map__1457__$1 = (((((!((map__1457 == null))))?(((((map__1457.cljs$lang$protocol_mask$partition0$ & (64))) || ((cljs.core.PROTOCOL_SENTINEL === map__1457.cljs$core$ISeq$))))?true:false):false))?cljs.core.apply.call(null,cljs.core.hash_map,map__1457):map__1457);
var m = map__1457__$1;
var n = cljs.core.get.call(null,map__1457__$1,new cljs.core.Keyword(null,"ns","ns",441598760));
var nm = cljs.core.get.call(null,map__1457__$1,new cljs.core.Keyword(null,"name","name",1843675177));
cljs.core.println.call(null,"-------------------------");

cljs.core.println.call(null,(function (){var or__4131__auto__ = new cljs.core.Keyword(null,"spec","spec",347520401).cljs$core$IFn$_invoke$arity$1(m);
if(cljs.core.truth_(or__4131__auto__)){
return or__4131__auto__;
} else {
return [(function (){var temp__5720__auto__ = new cljs.core.Keyword(null,"ns","ns",441598760).cljs$core$IFn$_invoke$arity$1(m);
if(cljs.core.truth_(temp__5720__auto__)){
var ns = temp__5720__auto__;
return [cljs.core.str.cljs$core$IFn$_invoke$arity$1(ns),"/"].join('');
} else {
return null;
}
})(),cljs.core.str.cljs$core$IFn$_invoke$arity$1(new cljs.core.Keyword(null,"name","name",1843675177).cljs$core$IFn$_invoke$arity$1(m))].join('');
}
})());

if(cljs.core.truth_(new cljs.core.Keyword(null,"protocol","protocol",652470118).cljs$core$IFn$_invoke$arity$1(m))){
cljs.core.println.call(null,"Protocol");
} else {
}

if(cljs.core.truth_(new cljs.core.Keyword(null,"forms","forms",2045992350).cljs$core$IFn$_invoke$arity$1(m))){
var seq__1459_1491 = cljs.core.seq.call(null,new cljs.core.Keyword(null,"forms","forms",2045992350).cljs$core$IFn$_invoke$arity$1(m));
var chunk__1460_1492 = null;
var count__1461_1493 = (0);
var i__1462_1494 = (0);
while(true){
if((i__1462_1494 < count__1461_1493)){
var f_1495 = cljs.core._nth.call(null,chunk__1460_1492,i__1462_1494);
cljs.core.println.call(null,"  ",f_1495);


var G__1496 = seq__1459_1491;
var G__1497 = chunk__1460_1492;
var G__1498 = count__1461_1493;
var G__1499 = (i__1462_1494 + (1));
seq__1459_1491 = G__1496;
chunk__1460_1492 = G__1497;
count__1461_1493 = G__1498;
i__1462_1494 = G__1499;
continue;
} else {
var temp__5720__auto___1500 = cljs.core.seq.call(null,seq__1459_1491);
if(temp__5720__auto___1500){
var seq__1459_1501__$1 = temp__5720__auto___1500;
if(cljs.core.chunked_seq_QMARK_.call(null,seq__1459_1501__$1)){
var c__4550__auto___1502 = cljs.core.chunk_first.call(null,seq__1459_1501__$1);
var G__1503 = cljs.core.chunk_rest.call(null,seq__1459_1501__$1);
var G__1504 = c__4550__auto___1502;
var G__1505 = cljs.core.count.call(null,c__4550__auto___1502);
var G__1506 = (0);
seq__1459_1491 = G__1503;
chunk__1460_1492 = G__1504;
count__1461_1493 = G__1505;
i__1462_1494 = G__1506;
continue;
} else {
var f_1507 = cljs.core.first.call(null,seq__1459_1501__$1);
cljs.core.println.call(null,"  ",f_1507);


var G__1508 = cljs.core.next.call(null,seq__1459_1501__$1);
var G__1509 = null;
var G__1510 = (0);
var G__1511 = (0);
seq__1459_1491 = G__1508;
chunk__1460_1492 = G__1509;
count__1461_1493 = G__1510;
i__1462_1494 = G__1511;
continue;
}
} else {
}
}
break;
}
} else {
if(cljs.core.truth_(new cljs.core.Keyword(null,"arglists","arglists",1661989754).cljs$core$IFn$_invoke$arity$1(m))){
var arglists_1512 = new cljs.core.Keyword(null,"arglists","arglists",1661989754).cljs$core$IFn$_invoke$arity$1(m);
if(cljs.core.truth_((function (){var or__4131__auto__ = new cljs.core.Keyword(null,"macro","macro",-867863404).cljs$core$IFn$_invoke$arity$1(m);
if(cljs.core.truth_(or__4131__auto__)){
return or__4131__auto__;
} else {
return new cljs.core.Keyword(null,"repl-special-function","repl-special-function",1262603725).cljs$core$IFn$_invoke$arity$1(m);
}
})())){
cljs.core.prn.call(null,arglists_1512);
} else {
cljs.core.prn.call(null,((cljs.core._EQ_.call(null,new cljs.core.Symbol(null,"quote","quote",1377916282,null),cljs.core.first.call(null,arglists_1512)))?cljs.core.second.call(null,arglists_1512):arglists_1512));
}
} else {
}
}

if(cljs.core.truth_(new cljs.core.Keyword(null,"special-form","special-form",-1326536374).cljs$core$IFn$_invoke$arity$1(m))){
cljs.core.println.call(null,"Special Form");

cljs.core.println.call(null," ",new cljs.core.Keyword(null,"doc","doc",1913296891).cljs$core$IFn$_invoke$arity$1(m));

if(cljs.core.contains_QMARK_.call(null,m,new cljs.core.Keyword(null,"url","url",276297046))){
if(cljs.core.truth_(new cljs.core.Keyword(null,"url","url",276297046).cljs$core$IFn$_invoke$arity$1(m))){
return cljs.core.println.call(null,["\n  Please see http://clojure.org/",cljs.core.str.cljs$core$IFn$_invoke$arity$1(new cljs.core.Keyword(null,"url","url",276297046).cljs$core$IFn$_invoke$arity$1(m))].join(''));
} else {
return null;
}
} else {
return cljs.core.println.call(null,["\n  Please see http://clojure.org/special_forms#",cljs.core.str.cljs$core$IFn$_invoke$arity$1(new cljs.core.Keyword(null,"name","name",1843675177).cljs$core$IFn$_invoke$arity$1(m))].join(''));
}
} else {
if(cljs.core.truth_(new cljs.core.Keyword(null,"macro","macro",-867863404).cljs$core$IFn$_invoke$arity$1(m))){
cljs.core.println.call(null,"Macro");
} else {
}

if(cljs.core.truth_(new cljs.core.Keyword(null,"spec","spec",347520401).cljs$core$IFn$_invoke$arity$1(m))){
cljs.core.println.call(null,"Spec");
} else {
}

if(cljs.core.truth_(new cljs.core.Keyword(null,"repl-special-function","repl-special-function",1262603725).cljs$core$IFn$_invoke$arity$1(m))){
cljs.core.println.call(null,"REPL Special Function");
} else {
}

cljs.core.println.call(null," ",new cljs.core.Keyword(null,"doc","doc",1913296891).cljs$core$IFn$_invoke$arity$1(m));

if(cljs.core.truth_(new cljs.core.Keyword(null,"protocol","protocol",652470118).cljs$core$IFn$_invoke$arity$1(m))){
var seq__1463_1513 = cljs.core.seq.call(null,new cljs.core.Keyword(null,"methods","methods",453930866).cljs$core$IFn$_invoke$arity$1(m));
var chunk__1464_1514 = null;
var count__1465_1515 = (0);
var i__1466_1516 = (0);
while(true){
if((i__1466_1516 < count__1465_1515)){
var vec__1477_1517 = cljs.core._nth.call(null,chunk__1464_1514,i__1466_1516);
var name_1518 = cljs.core.nth.call(null,vec__1477_1517,(0),null);
var map__1480_1519 = cljs.core.nth.call(null,vec__1477_1517,(1),null);
var map__1480_1520__$1 = (((((!((map__1480_1519 == null))))?(((((map__1480_1519.cljs$lang$protocol_mask$partition0$ & (64))) || ((cljs.core.PROTOCOL_SENTINEL === map__1480_1519.cljs$core$ISeq$))))?true:false):false))?cljs.core.apply.call(null,cljs.core.hash_map,map__1480_1519):map__1480_1519);
var doc_1521 = cljs.core.get.call(null,map__1480_1520__$1,new cljs.core.Keyword(null,"doc","doc",1913296891));
var arglists_1522 = cljs.core.get.call(null,map__1480_1520__$1,new cljs.core.Keyword(null,"arglists","arglists",1661989754));
cljs.core.println.call(null);

cljs.core.println.call(null," ",name_1518);

cljs.core.println.call(null," ",arglists_1522);

if(cljs.core.truth_(doc_1521)){
cljs.core.println.call(null," ",doc_1521);
} else {
}


var G__1523 = seq__1463_1513;
var G__1524 = chunk__1464_1514;
var G__1525 = count__1465_1515;
var G__1526 = (i__1466_1516 + (1));
seq__1463_1513 = G__1523;
chunk__1464_1514 = G__1524;
count__1465_1515 = G__1525;
i__1466_1516 = G__1526;
continue;
} else {
var temp__5720__auto___1527 = cljs.core.seq.call(null,seq__1463_1513);
if(temp__5720__auto___1527){
var seq__1463_1528__$1 = temp__5720__auto___1527;
if(cljs.core.chunked_seq_QMARK_.call(null,seq__1463_1528__$1)){
var c__4550__auto___1529 = cljs.core.chunk_first.call(null,seq__1463_1528__$1);
var G__1530 = cljs.core.chunk_rest.call(null,seq__1463_1528__$1);
var G__1531 = c__4550__auto___1529;
var G__1532 = cljs.core.count.call(null,c__4550__auto___1529);
var G__1533 = (0);
seq__1463_1513 = G__1530;
chunk__1464_1514 = G__1531;
count__1465_1515 = G__1532;
i__1466_1516 = G__1533;
continue;
} else {
var vec__1482_1534 = cljs.core.first.call(null,seq__1463_1528__$1);
var name_1535 = cljs.core.nth.call(null,vec__1482_1534,(0),null);
var map__1485_1536 = cljs.core.nth.call(null,vec__1482_1534,(1),null);
var map__1485_1537__$1 = (((((!((map__1485_1536 == null))))?(((((map__1485_1536.cljs$lang$protocol_mask$partition0$ & (64))) || ((cljs.core.PROTOCOL_SENTINEL === map__1485_1536.cljs$core$ISeq$))))?true:false):false))?cljs.core.apply.call(null,cljs.core.hash_map,map__1485_1536):map__1485_1536);
var doc_1538 = cljs.core.get.call(null,map__1485_1537__$1,new cljs.core.Keyword(null,"doc","doc",1913296891));
var arglists_1539 = cljs.core.get.call(null,map__1485_1537__$1,new cljs.core.Keyword(null,"arglists","arglists",1661989754));
cljs.core.println.call(null);

cljs.core.println.call(null," ",name_1535);

cljs.core.println.call(null," ",arglists_1539);

if(cljs.core.truth_(doc_1538)){
cljs.core.println.call(null," ",doc_1538);
} else {
}


var G__1540 = cljs.core.next.call(null,seq__1463_1528__$1);
var G__1541 = null;
var G__1542 = (0);
var G__1543 = (0);
seq__1463_1513 = G__1540;
chunk__1464_1514 = G__1541;
count__1465_1515 = G__1542;
i__1466_1516 = G__1543;
continue;
}
} else {
}
}
break;
}
} else {
}

if(cljs.core.truth_(n)){
var temp__5720__auto__ = cljs.spec.alpha.get_spec.call(null,cljs.core.symbol.call(null,cljs.core.str.cljs$core$IFn$_invoke$arity$1(cljs.core.ns_name.call(null,n)),cljs.core.name.call(null,nm)));
if(cljs.core.truth_(temp__5720__auto__)){
var fnspec = temp__5720__auto__;
cljs.core.print.call(null,"Spec");

var seq__1487 = cljs.core.seq.call(null,new cljs.core.PersistentVector(null, 3, 5, cljs.core.PersistentVector.EMPTY_NODE, [new cljs.core.Keyword(null,"args","args",1315556576),new cljs.core.Keyword(null,"ret","ret",-468222814),new cljs.core.Keyword(null,"fn","fn",-1175266204)], null));
var chunk__1488 = null;
var count__1489 = (0);
var i__1490 = (0);
while(true){
if((i__1490 < count__1489)){
var role = cljs.core._nth.call(null,chunk__1488,i__1490);
var temp__5720__auto___1544__$1 = cljs.core.get.call(null,fnspec,role);
if(cljs.core.truth_(temp__5720__auto___1544__$1)){
var spec_1545 = temp__5720__auto___1544__$1;
cljs.core.print.call(null,["\n ",cljs.core.name.call(null,role),":"].join(''),cljs.spec.alpha.describe.call(null,spec_1545));
} else {
}


var G__1546 = seq__1487;
var G__1547 = chunk__1488;
var G__1548 = count__1489;
var G__1549 = (i__1490 + (1));
seq__1487 = G__1546;
chunk__1488 = G__1547;
count__1489 = G__1548;
i__1490 = G__1549;
continue;
} else {
var temp__5720__auto____$1 = cljs.core.seq.call(null,seq__1487);
if(temp__5720__auto____$1){
var seq__1487__$1 = temp__5720__auto____$1;
if(cljs.core.chunked_seq_QMARK_.call(null,seq__1487__$1)){
var c__4550__auto__ = cljs.core.chunk_first.call(null,seq__1487__$1);
var G__1550 = cljs.core.chunk_rest.call(null,seq__1487__$1);
var G__1551 = c__4550__auto__;
var G__1552 = cljs.core.count.call(null,c__4550__auto__);
var G__1553 = (0);
seq__1487 = G__1550;
chunk__1488 = G__1551;
count__1489 = G__1552;
i__1490 = G__1553;
continue;
} else {
var role = cljs.core.first.call(null,seq__1487__$1);
var temp__5720__auto___1554__$2 = cljs.core.get.call(null,fnspec,role);
if(cljs.core.truth_(temp__5720__auto___1554__$2)){
var spec_1555 = temp__5720__auto___1554__$2;
cljs.core.print.call(null,["\n ",cljs.core.name.call(null,role),":"].join(''),cljs.spec.alpha.describe.call(null,spec_1555));
} else {
}


var G__1556 = cljs.core.next.call(null,seq__1487__$1);
var G__1557 = null;
var G__1558 = (0);
var G__1559 = (0);
seq__1487 = G__1556;
chunk__1488 = G__1557;
count__1489 = G__1558;
i__1490 = G__1559;
continue;
}
} else {
return null;
}
}
break;
}
} else {
return null;
}
} else {
return null;
}
}
});
/**
 * Constructs a data representation for a Error with keys:
 *  :cause - root cause message
 *  :phase - error phase
 *  :via - cause chain, with cause keys:
 *           :type - exception class symbol
 *           :message - exception message
 *           :data - ex-data
 *           :at - top stack element
 *  :trace - root cause stack elements
 */
cljs.repl.Error__GT_map = (function cljs$repl$Error__GT_map(o){
var base = (function (t){
return cljs.core.merge.call(null,new cljs.core.PersistentArrayMap(null, 1, [new cljs.core.Keyword(null,"type","type",1174270348),(((t instanceof cljs.core.ExceptionInfo))?new cljs.core.Symbol(null,"ExceptionInfo","ExceptionInfo",294935087,null):(((t instanceof EvalError))?new cljs.core.Symbol("js","EvalError","js/EvalError",1793498501,null):(((t instanceof RangeError))?new cljs.core.Symbol("js","RangeError","js/RangeError",1703848089,null):(((t instanceof ReferenceError))?new cljs.core.Symbol("js","ReferenceError","js/ReferenceError",-198403224,null):(((t instanceof SyntaxError))?new cljs.core.Symbol("js","SyntaxError","js/SyntaxError",-1527651665,null):(((t instanceof URIError))?new cljs.core.Symbol("js","URIError","js/URIError",505061350,null):(((t instanceof Error))?new cljs.core.Symbol("js","Error","js/Error",-1692659266,null):null
)))))))], null),(function (){var temp__5720__auto__ = cljs.core.ex_message.call(null,t);
if(cljs.core.truth_(temp__5720__auto__)){
var msg = temp__5720__auto__;
return new cljs.core.PersistentArrayMap(null, 1, [new cljs.core.Keyword(null,"message","message",-406056002),msg], null);
} else {
return null;
}
})(),(function (){var temp__5720__auto__ = cljs.core.ex_data.call(null,t);
if(cljs.core.truth_(temp__5720__auto__)){
var ed = temp__5720__auto__;
return new cljs.core.PersistentArrayMap(null, 1, [new cljs.core.Keyword(null,"data","data",-232669377),ed], null);
} else {
return null;
}
})());
});
var via = (function (){var via = cljs.core.PersistentVector.EMPTY;
var t = o;
while(true){
if(cljs.core.truth_(t)){
var G__1560 = cljs.core.conj.call(null,via,t);
var G__1561 = cljs.core.ex_cause.call(null,t);
via = G__1560;
t = G__1561;
continue;
} else {
return via;
}
break;
}
})();
var root = cljs.core.peek.call(null,via);
return cljs.core.merge.call(null,new cljs.core.PersistentArrayMap(null, 2, [new cljs.core.Keyword(null,"via","via",-1904457336),cljs.core.vec.call(null,cljs.core.map.call(null,base,via)),new cljs.core.Keyword(null,"trace","trace",-1082747415),null], null),(function (){var temp__5720__auto__ = cljs.core.ex_message.call(null,root);
if(cljs.core.truth_(temp__5720__auto__)){
var root_msg = temp__5720__auto__;
return new cljs.core.PersistentArrayMap(null, 1, [new cljs.core.Keyword(null,"cause","cause",231901252),root_msg], null);
} else {
return null;
}
})(),(function (){var temp__5720__auto__ = cljs.core.ex_data.call(null,root);
if(cljs.core.truth_(temp__5720__auto__)){
var data = temp__5720__auto__;
return new cljs.core.PersistentArrayMap(null, 1, [new cljs.core.Keyword(null,"data","data",-232669377),data], null);
} else {
return null;
}
})(),(function (){var temp__5720__auto__ = new cljs.core.Keyword("clojure.error","phase","clojure.error/phase",275140358).cljs$core$IFn$_invoke$arity$1(cljs.core.ex_data.call(null,o));
if(cljs.core.truth_(temp__5720__auto__)){
var phase = temp__5720__auto__;
return new cljs.core.PersistentArrayMap(null, 1, [new cljs.core.Keyword(null,"phase","phase",575722892),phase], null);
} else {
return null;
}
})());
});
/**
 * Returns an analysis of the phase, error, cause, and location of an error that occurred
 *   based on Throwable data, as returned by Throwable->map. All attributes other than phase
 *   are optional:
 *  :clojure.error/phase - keyword phase indicator, one of:
 *    :read-source :compile-syntax-check :compilation :macro-syntax-check :macroexpansion
 *    :execution :read-eval-result :print-eval-result
 *  :clojure.error/source - file name (no path)
 *  :clojure.error/line - integer line number
 *  :clojure.error/column - integer column number
 *  :clojure.error/symbol - symbol being expanded/compiled/invoked
 *  :clojure.error/class - cause exception class symbol
 *  :clojure.error/cause - cause exception message
 *  :clojure.error/spec - explain-data for spec error
 */
cljs.repl.ex_triage = (function cljs$repl$ex_triage(datafied_throwable){
var map__1564 = datafied_throwable;
var map__1564__$1 = (((((!((map__1564 == null))))?(((((map__1564.cljs$lang$protocol_mask$partition0$ & (64))) || ((cljs.core.PROTOCOL_SENTINEL === map__1564.cljs$core$ISeq$))))?true:false):false))?cljs.core.apply.call(null,cljs.core.hash_map,map__1564):map__1564);
var via = cljs.core.get.call(null,map__1564__$1,new cljs.core.Keyword(null,"via","via",-1904457336));
var trace = cljs.core.get.call(null,map__1564__$1,new cljs.core.Keyword(null,"trace","trace",-1082747415));
var phase = cljs.core.get.call(null,map__1564__$1,new cljs.core.Keyword(null,"phase","phase",575722892),new cljs.core.Keyword(null,"execution","execution",253283524));
var map__1565 = cljs.core.last.call(null,via);
var map__1565__$1 = (((((!((map__1565 == null))))?(((((map__1565.cljs$lang$protocol_mask$partition0$ & (64))) || ((cljs.core.PROTOCOL_SENTINEL === map__1565.cljs$core$ISeq$))))?true:false):false))?cljs.core.apply.call(null,cljs.core.hash_map,map__1565):map__1565);
var type = cljs.core.get.call(null,map__1565__$1,new cljs.core.Keyword(null,"type","type",1174270348));
var message = cljs.core.get.call(null,map__1565__$1,new cljs.core.Keyword(null,"message","message",-406056002));
var data = cljs.core.get.call(null,map__1565__$1,new cljs.core.Keyword(null,"data","data",-232669377));
var map__1566 = data;
var map__1566__$1 = (((((!((map__1566 == null))))?(((((map__1566.cljs$lang$protocol_mask$partition0$ & (64))) || ((cljs.core.PROTOCOL_SENTINEL === map__1566.cljs$core$ISeq$))))?true:false):false))?cljs.core.apply.call(null,cljs.core.hash_map,map__1566):map__1566);
var problems = cljs.core.get.call(null,map__1566__$1,new cljs.core.Keyword("cljs.spec.alpha","problems","cljs.spec.alpha/problems",447400814));
var fn = cljs.core.get.call(null,map__1566__$1,new cljs.core.Keyword("cljs.spec.alpha","fn","cljs.spec.alpha/fn",408600443));
var caller = cljs.core.get.call(null,map__1566__$1,new cljs.core.Keyword("cljs.spec.test.alpha","caller","cljs.spec.test.alpha/caller",-398302390));
var map__1567 = new cljs.core.Keyword(null,"data","data",-232669377).cljs$core$IFn$_invoke$arity$1(cljs.core.first.call(null,via));
var map__1567__$1 = (((((!((map__1567 == null))))?(((((map__1567.cljs$lang$protocol_mask$partition0$ & (64))) || ((cljs.core.PROTOCOL_SENTINEL === map__1567.cljs$core$ISeq$))))?true:false):false))?cljs.core.apply.call(null,cljs.core.hash_map,map__1567):map__1567);
var top_data = map__1567__$1;
var source = cljs.core.get.call(null,map__1567__$1,new cljs.core.Keyword("clojure.error","source","clojure.error/source",-2011936397));
return cljs.core.assoc.call(null,(function (){var G__1572 = phase;
var G__1572__$1 = (((G__1572 instanceof cljs.core.Keyword))?G__1572.fqn:null);
switch (G__1572__$1) {
case "read-source":
var map__1573 = data;
var map__1573__$1 = (((((!((map__1573 == null))))?(((((map__1573.cljs$lang$protocol_mask$partition0$ & (64))) || ((cljs.core.PROTOCOL_SENTINEL === map__1573.cljs$core$ISeq$))))?true:false):false))?cljs.core.apply.call(null,cljs.core.hash_map,map__1573):map__1573);
var line = cljs.core.get.call(null,map__1573__$1,new cljs.core.Keyword("clojure.error","line","clojure.error/line",-1816287471));
var column = cljs.core.get.call(null,map__1573__$1,new cljs.core.Keyword("clojure.error","column","clojure.error/column",304721553));
var G__1575 = cljs.core.merge.call(null,new cljs.core.Keyword(null,"data","data",-232669377).cljs$core$IFn$_invoke$arity$1(cljs.core.second.call(null,via)),top_data);
var G__1575__$1 = (cljs.core.truth_(source)?cljs.core.assoc.call(null,G__1575,new cljs.core.Keyword("clojure.error","source","clojure.error/source",-2011936397),source):G__1575);
var G__1575__$2 = (cljs.core.truth_(new cljs.core.PersistentHashSet(null, new cljs.core.PersistentArrayMap(null, 2, ["NO_SOURCE_PATH",null,"NO_SOURCE_FILE",null], null), null).call(null,source))?cljs.core.dissoc.call(null,G__1575__$1,new cljs.core.Keyword("clojure.error","source","clojure.error/source",-2011936397)):G__1575__$1);
if(cljs.core.truth_(message)){
return cljs.core.assoc.call(null,G__1575__$2,new cljs.core.Keyword("clojure.error","cause","clojure.error/cause",-1879175742),message);
} else {
return G__1575__$2;
}

break;
case "compile-syntax-check":
case "compilation":
case "macro-syntax-check":
case "macroexpansion":
var G__1576 = top_data;
var G__1576__$1 = (cljs.core.truth_(source)?cljs.core.assoc.call(null,G__1576,new cljs.core.Keyword("clojure.error","source","clojure.error/source",-2011936397),source):G__1576);
var G__1576__$2 = (cljs.core.truth_(new cljs.core.PersistentHashSet(null, new cljs.core.PersistentArrayMap(null, 2, ["NO_SOURCE_PATH",null,"NO_SOURCE_FILE",null], null), null).call(null,source))?cljs.core.dissoc.call(null,G__1576__$1,new cljs.core.Keyword("clojure.error","source","clojure.error/source",-2011936397)):G__1576__$1);
var G__1576__$3 = (cljs.core.truth_(type)?cljs.core.assoc.call(null,G__1576__$2,new cljs.core.Keyword("clojure.error","class","clojure.error/class",278435890),type):G__1576__$2);
var G__1576__$4 = (cljs.core.truth_(message)?cljs.core.assoc.call(null,G__1576__$3,new cljs.core.Keyword("clojure.error","cause","clojure.error/cause",-1879175742),message):G__1576__$3);
if(cljs.core.truth_(problems)){
return cljs.core.assoc.call(null,G__1576__$4,new cljs.core.Keyword("clojure.error","spec","clojure.error/spec",2055032595),data);
} else {
return G__1576__$4;
}

break;
case "read-eval-result":
case "print-eval-result":
var vec__1577 = cljs.core.first.call(null,trace);
var source__$1 = cljs.core.nth.call(null,vec__1577,(0),null);
var method = cljs.core.nth.call(null,vec__1577,(1),null);
var file = cljs.core.nth.call(null,vec__1577,(2),null);
var line = cljs.core.nth.call(null,vec__1577,(3),null);
var G__1580 = top_data;
var G__1580__$1 = (cljs.core.truth_(line)?cljs.core.assoc.call(null,G__1580,new cljs.core.Keyword("clojure.error","line","clojure.error/line",-1816287471),line):G__1580);
var G__1580__$2 = (cljs.core.truth_(file)?cljs.core.assoc.call(null,G__1580__$1,new cljs.core.Keyword("clojure.error","source","clojure.error/source",-2011936397),file):G__1580__$1);
var G__1580__$3 = (cljs.core.truth_((function (){var and__4120__auto__ = source__$1;
if(cljs.core.truth_(and__4120__auto__)){
return method;
} else {
return and__4120__auto__;
}
})())?cljs.core.assoc.call(null,G__1580__$2,new cljs.core.Keyword("clojure.error","symbol","clojure.error/symbol",1544821994),(new cljs.core.PersistentVector(null,2,(5),cljs.core.PersistentVector.EMPTY_NODE,[source__$1,method],null))):G__1580__$2);
var G__1580__$4 = (cljs.core.truth_(type)?cljs.core.assoc.call(null,G__1580__$3,new cljs.core.Keyword("clojure.error","class","clojure.error/class",278435890),type):G__1580__$3);
if(cljs.core.truth_(message)){
return cljs.core.assoc.call(null,G__1580__$4,new cljs.core.Keyword("clojure.error","cause","clojure.error/cause",-1879175742),message);
} else {
return G__1580__$4;
}

break;
case "execution":
var vec__1581 = cljs.core.first.call(null,trace);
var source__$1 = cljs.core.nth.call(null,vec__1581,(0),null);
var method = cljs.core.nth.call(null,vec__1581,(1),null);
var file = cljs.core.nth.call(null,vec__1581,(2),null);
var line = cljs.core.nth.call(null,vec__1581,(3),null);
var file__$1 = cljs.core.first.call(null,cljs.core.remove.call(null,((function (vec__1581,source__$1,method,file,line,G__1572,G__1572__$1,map__1564,map__1564__$1,via,trace,phase,map__1565,map__1565__$1,type,message,data,map__1566,map__1566__$1,problems,fn,caller,map__1567,map__1567__$1,top_data,source){
return (function (p1__1563_SHARP_){
var or__4131__auto__ = (p1__1563_SHARP_ == null);
if(or__4131__auto__){
return or__4131__auto__;
} else {
return new cljs.core.PersistentHashSet(null, new cljs.core.PersistentArrayMap(null, 2, ["NO_SOURCE_PATH",null,"NO_SOURCE_FILE",null], null), null).call(null,p1__1563_SHARP_);
}
});})(vec__1581,source__$1,method,file,line,G__1572,G__1572__$1,map__1564,map__1564__$1,via,trace,phase,map__1565,map__1565__$1,type,message,data,map__1566,map__1566__$1,problems,fn,caller,map__1567,map__1567__$1,top_data,source))
,new cljs.core.PersistentVector(null, 2, 5, cljs.core.PersistentVector.EMPTY_NODE, [new cljs.core.Keyword(null,"file","file",-1269645878).cljs$core$IFn$_invoke$arity$1(caller),file], null)));
var err_line = (function (){var or__4131__auto__ = new cljs.core.Keyword(null,"line","line",212345235).cljs$core$IFn$_invoke$arity$1(caller);
if(cljs.core.truth_(or__4131__auto__)){
return or__4131__auto__;
} else {
return line;
}
})();
var G__1584 = new cljs.core.PersistentArrayMap(null, 1, [new cljs.core.Keyword("clojure.error","class","clojure.error/class",278435890),type], null);
var G__1584__$1 = (cljs.core.truth_(err_line)?cljs.core.assoc.call(null,G__1584,new cljs.core.Keyword("clojure.error","line","clojure.error/line",-1816287471),err_line):G__1584);
var G__1584__$2 = (cljs.core.truth_(message)?cljs.core.assoc.call(null,G__1584__$1,new cljs.core.Keyword("clojure.error","cause","clojure.error/cause",-1879175742),message):G__1584__$1);
var G__1584__$3 = (cljs.core.truth_((function (){var or__4131__auto__ = fn;
if(cljs.core.truth_(or__4131__auto__)){
return or__4131__auto__;
} else {
var and__4120__auto__ = source__$1;
if(cljs.core.truth_(and__4120__auto__)){
return method;
} else {
return and__4120__auto__;
}
}
})())?cljs.core.assoc.call(null,G__1584__$2,new cljs.core.Keyword("clojure.error","symbol","clojure.error/symbol",1544821994),(function (){var or__4131__auto__ = fn;
if(cljs.core.truth_(or__4131__auto__)){
return or__4131__auto__;
} else {
return (new cljs.core.PersistentVector(null,2,(5),cljs.core.PersistentVector.EMPTY_NODE,[source__$1,method],null));
}
})()):G__1584__$2);
var G__1584__$4 = (cljs.core.truth_(file__$1)?cljs.core.assoc.call(null,G__1584__$3,new cljs.core.Keyword("clojure.error","source","clojure.error/source",-2011936397),file__$1):G__1584__$3);
if(cljs.core.truth_(problems)){
return cljs.core.assoc.call(null,G__1584__$4,new cljs.core.Keyword("clojure.error","spec","clojure.error/spec",2055032595),data);
} else {
return G__1584__$4;
}

break;
default:
throw (new Error(["No matching clause: ",cljs.core.str.cljs$core$IFn$_invoke$arity$1(G__1572__$1)].join('')));

}
})(),new cljs.core.Keyword("clojure.error","phase","clojure.error/phase",275140358),phase);
});
/**
 * Returns a string from exception data, as produced by ex-triage.
 *   The first line summarizes the exception phase and location.
 *   The subsequent lines describe the cause.
 */
cljs.repl.ex_str = (function cljs$repl$ex_str(p__1588){
var map__1589 = p__1588;
var map__1589__$1 = (((((!((map__1589 == null))))?(((((map__1589.cljs$lang$protocol_mask$partition0$ & (64))) || ((cljs.core.PROTOCOL_SENTINEL === map__1589.cljs$core$ISeq$))))?true:false):false))?cljs.core.apply.call(null,cljs.core.hash_map,map__1589):map__1589);
var triage_data = map__1589__$1;
var phase = cljs.core.get.call(null,map__1589__$1,new cljs.core.Keyword("clojure.error","phase","clojure.error/phase",275140358));
var source = cljs.core.get.call(null,map__1589__$1,new cljs.core.Keyword("clojure.error","source","clojure.error/source",-2011936397));
var line = cljs.core.get.call(null,map__1589__$1,new cljs.core.Keyword("clojure.error","line","clojure.error/line",-1816287471));
var column = cljs.core.get.call(null,map__1589__$1,new cljs.core.Keyword("clojure.error","column","clojure.error/column",304721553));
var symbol = cljs.core.get.call(null,map__1589__$1,new cljs.core.Keyword("clojure.error","symbol","clojure.error/symbol",1544821994));
var class$ = cljs.core.get.call(null,map__1589__$1,new cljs.core.Keyword("clojure.error","class","clojure.error/class",278435890));
var cause = cljs.core.get.call(null,map__1589__$1,new cljs.core.Keyword("clojure.error","cause","clojure.error/cause",-1879175742));
var spec = cljs.core.get.call(null,map__1589__$1,new cljs.core.Keyword("clojure.error","spec","clojure.error/spec",2055032595));
var loc = [cljs.core.str.cljs$core$IFn$_invoke$arity$1((function (){var or__4131__auto__ = source;
if(cljs.core.truth_(or__4131__auto__)){
return or__4131__auto__;
} else {
return "<cljs repl>";
}
})()),":",cljs.core.str.cljs$core$IFn$_invoke$arity$1((function (){var or__4131__auto__ = line;
if(cljs.core.truth_(or__4131__auto__)){
return or__4131__auto__;
} else {
return (1);
}
})()),(cljs.core.truth_(column)?[":",cljs.core.str.cljs$core$IFn$_invoke$arity$1(column)].join(''):"")].join('');
var class_name = cljs.core.name.call(null,(function (){var or__4131__auto__ = class$;
if(cljs.core.truth_(or__4131__auto__)){
return or__4131__auto__;
} else {
return "";
}
})());
var simple_class = class_name;
var cause_type = ((cljs.core.contains_QMARK_.call(null,new cljs.core.PersistentHashSet(null, new cljs.core.PersistentArrayMap(null, 2, ["RuntimeException",null,"Exception",null], null), null),simple_class))?"":[" (",simple_class,")"].join(''));
var format = goog.string.format;
var G__1591 = phase;
var G__1591__$1 = (((G__1591 instanceof cljs.core.Keyword))?G__1591.fqn:null);
switch (G__1591__$1) {
case "read-source":
return format.call(null,"Syntax error reading source at (%s).\n%s\n",loc,cause);

break;
case "macro-syntax-check":
return format.call(null,"Syntax error macroexpanding %sat (%s).\n%s",(cljs.core.truth_(symbol)?[cljs.core.str.cljs$core$IFn$_invoke$arity$1(symbol)," "].join(''):""),loc,(cljs.core.truth_(spec)?(function (){var sb__4661__auto__ = (new goog.string.StringBuffer());
var _STAR_print_newline_STAR__orig_val__1592_1601 = cljs.core._STAR_print_newline_STAR_;
var _STAR_print_fn_STAR__orig_val__1593_1602 = cljs.core._STAR_print_fn_STAR_;
var _STAR_print_newline_STAR__temp_val__1594_1603 = true;
var _STAR_print_fn_STAR__temp_val__1595_1604 = ((function (_STAR_print_newline_STAR__orig_val__1592_1601,_STAR_print_fn_STAR__orig_val__1593_1602,_STAR_print_newline_STAR__temp_val__1594_1603,sb__4661__auto__,G__1591,G__1591__$1,loc,class_name,simple_class,cause_type,format,map__1589,map__1589__$1,triage_data,phase,source,line,column,symbol,class$,cause,spec){
return (function (x__4662__auto__){
return sb__4661__auto__.append(x__4662__auto__);
});})(_STAR_print_newline_STAR__orig_val__1592_1601,_STAR_print_fn_STAR__orig_val__1593_1602,_STAR_print_newline_STAR__temp_val__1594_1603,sb__4661__auto__,G__1591,G__1591__$1,loc,class_name,simple_class,cause_type,format,map__1589,map__1589__$1,triage_data,phase,source,line,column,symbol,class$,cause,spec))
;
cljs.core._STAR_print_newline_STAR_ = _STAR_print_newline_STAR__temp_val__1594_1603;

cljs.core._STAR_print_fn_STAR_ = _STAR_print_fn_STAR__temp_val__1595_1604;

try{cljs.spec.alpha.explain_out.call(null,cljs.core.update.call(null,spec,new cljs.core.Keyword("cljs.spec.alpha","problems","cljs.spec.alpha/problems",447400814),((function (_STAR_print_newline_STAR__orig_val__1592_1601,_STAR_print_fn_STAR__orig_val__1593_1602,_STAR_print_newline_STAR__temp_val__1594_1603,_STAR_print_fn_STAR__temp_val__1595_1604,sb__4661__auto__,G__1591,G__1591__$1,loc,class_name,simple_class,cause_type,format,map__1589,map__1589__$1,triage_data,phase,source,line,column,symbol,class$,cause,spec){
return (function (probs){
return cljs.core.map.call(null,((function (_STAR_print_newline_STAR__orig_val__1592_1601,_STAR_print_fn_STAR__orig_val__1593_1602,_STAR_print_newline_STAR__temp_val__1594_1603,_STAR_print_fn_STAR__temp_val__1595_1604,sb__4661__auto__,G__1591,G__1591__$1,loc,class_name,simple_class,cause_type,format,map__1589,map__1589__$1,triage_data,phase,source,line,column,symbol,class$,cause,spec){
return (function (p1__1586_SHARP_){
return cljs.core.dissoc.call(null,p1__1586_SHARP_,new cljs.core.Keyword(null,"in","in",-1531184865));
});})(_STAR_print_newline_STAR__orig_val__1592_1601,_STAR_print_fn_STAR__orig_val__1593_1602,_STAR_print_newline_STAR__temp_val__1594_1603,_STAR_print_fn_STAR__temp_val__1595_1604,sb__4661__auto__,G__1591,G__1591__$1,loc,class_name,simple_class,cause_type,format,map__1589,map__1589__$1,triage_data,phase,source,line,column,symbol,class$,cause,spec))
,probs);
});})(_STAR_print_newline_STAR__orig_val__1592_1601,_STAR_print_fn_STAR__orig_val__1593_1602,_STAR_print_newline_STAR__temp_val__1594_1603,_STAR_print_fn_STAR__temp_val__1595_1604,sb__4661__auto__,G__1591,G__1591__$1,loc,class_name,simple_class,cause_type,format,map__1589,map__1589__$1,triage_data,phase,source,line,column,symbol,class$,cause,spec))
)
);
}finally {cljs.core._STAR_print_fn_STAR_ = _STAR_print_fn_STAR__orig_val__1593_1602;

cljs.core._STAR_print_newline_STAR_ = _STAR_print_newline_STAR__orig_val__1592_1601;
}
return cljs.core.str.cljs$core$IFn$_invoke$arity$1(sb__4661__auto__);
})():format.call(null,"%s\n",cause)));

break;
case "macroexpansion":
return format.call(null,"Unexpected error%s macroexpanding %sat (%s).\n%s\n",cause_type,(cljs.core.truth_(symbol)?[cljs.core.str.cljs$core$IFn$_invoke$arity$1(symbol)," "].join(''):""),loc,cause);

break;
case "compile-syntax-check":
return format.call(null,"Syntax error%s compiling %sat (%s).\n%s\n",cause_type,(cljs.core.truth_(symbol)?[cljs.core.str.cljs$core$IFn$_invoke$arity$1(symbol)," "].join(''):""),loc,cause);

break;
case "compilation":
return format.call(null,"Unexpected error%s compiling %sat (%s).\n%s\n",cause_type,(cljs.core.truth_(symbol)?[cljs.core.str.cljs$core$IFn$_invoke$arity$1(symbol)," "].join(''):""),loc,cause);

break;
case "read-eval-result":
return format.call(null,"Error reading eval result%s at %s (%s).\n%s\n",cause_type,symbol,loc,cause);

break;
case "print-eval-result":
return format.call(null,"Error printing return value%s at %s (%s).\n%s\n",cause_type,symbol,loc,cause);

break;
case "execution":
if(cljs.core.truth_(spec)){
return format.call(null,"Execution error - invalid arguments to %s at (%s).\n%s",symbol,loc,(function (){var sb__4661__auto__ = (new goog.string.StringBuffer());
var _STAR_print_newline_STAR__orig_val__1596_1605 = cljs.core._STAR_print_newline_STAR_;
var _STAR_print_fn_STAR__orig_val__1597_1606 = cljs.core._STAR_print_fn_STAR_;
var _STAR_print_newline_STAR__temp_val__1598_1607 = true;
var _STAR_print_fn_STAR__temp_val__1599_1608 = ((function (_STAR_print_newline_STAR__orig_val__1596_1605,_STAR_print_fn_STAR__orig_val__1597_1606,_STAR_print_newline_STAR__temp_val__1598_1607,sb__4661__auto__,G__1591,G__1591__$1,loc,class_name,simple_class,cause_type,format,map__1589,map__1589__$1,triage_data,phase,source,line,column,symbol,class$,cause,spec){
return (function (x__4662__auto__){
return sb__4661__auto__.append(x__4662__auto__);
});})(_STAR_print_newline_STAR__orig_val__1596_1605,_STAR_print_fn_STAR__orig_val__1597_1606,_STAR_print_newline_STAR__temp_val__1598_1607,sb__4661__auto__,G__1591,G__1591__$1,loc,class_name,simple_class,cause_type,format,map__1589,map__1589__$1,triage_data,phase,source,line,column,symbol,class$,cause,spec))
;
cljs.core._STAR_print_newline_STAR_ = _STAR_print_newline_STAR__temp_val__1598_1607;

cljs.core._STAR_print_fn_STAR_ = _STAR_print_fn_STAR__temp_val__1599_1608;

try{cljs.spec.alpha.explain_out.call(null,cljs.core.update.call(null,spec,new cljs.core.Keyword("cljs.spec.alpha","problems","cljs.spec.alpha/problems",447400814),((function (_STAR_print_newline_STAR__orig_val__1596_1605,_STAR_print_fn_STAR__orig_val__1597_1606,_STAR_print_newline_STAR__temp_val__1598_1607,_STAR_print_fn_STAR__temp_val__1599_1608,sb__4661__auto__,G__1591,G__1591__$1,loc,class_name,simple_class,cause_type,format,map__1589,map__1589__$1,triage_data,phase,source,line,column,symbol,class$,cause,spec){
return (function (probs){
return cljs.core.map.call(null,((function (_STAR_print_newline_STAR__orig_val__1596_1605,_STAR_print_fn_STAR__orig_val__1597_1606,_STAR_print_newline_STAR__temp_val__1598_1607,_STAR_print_fn_STAR__temp_val__1599_1608,sb__4661__auto__,G__1591,G__1591__$1,loc,class_name,simple_class,cause_type,format,map__1589,map__1589__$1,triage_data,phase,source,line,column,symbol,class$,cause,spec){
return (function (p1__1587_SHARP_){
return cljs.core.dissoc.call(null,p1__1587_SHARP_,new cljs.core.Keyword(null,"in","in",-1531184865));
});})(_STAR_print_newline_STAR__orig_val__1596_1605,_STAR_print_fn_STAR__orig_val__1597_1606,_STAR_print_newline_STAR__temp_val__1598_1607,_STAR_print_fn_STAR__temp_val__1599_1608,sb__4661__auto__,G__1591,G__1591__$1,loc,class_name,simple_class,cause_type,format,map__1589,map__1589__$1,triage_data,phase,source,line,column,symbol,class$,cause,spec))
,probs);
});})(_STAR_print_newline_STAR__orig_val__1596_1605,_STAR_print_fn_STAR__orig_val__1597_1606,_STAR_print_newline_STAR__temp_val__1598_1607,_STAR_print_fn_STAR__temp_val__1599_1608,sb__4661__auto__,G__1591,G__1591__$1,loc,class_name,simple_class,cause_type,format,map__1589,map__1589__$1,triage_data,phase,source,line,column,symbol,class$,cause,spec))
)
);
}finally {cljs.core._STAR_print_fn_STAR_ = _STAR_print_fn_STAR__orig_val__1597_1606;

cljs.core._STAR_print_newline_STAR_ = _STAR_print_newline_STAR__orig_val__1596_1605;
}
return cljs.core.str.cljs$core$IFn$_invoke$arity$1(sb__4661__auto__);
})());
} else {
return format.call(null,"Execution error%s at %s(%s).\n%s\n",cause_type,(cljs.core.truth_(symbol)?[cljs.core.str.cljs$core$IFn$_invoke$arity$1(symbol)," "].join(''):""),loc,cause);
}

break;
default:
throw (new Error(["No matching clause: ",cljs.core.str.cljs$core$IFn$_invoke$arity$1(G__1591__$1)].join('')));

}
});
cljs.repl.error__GT_str = (function cljs$repl$error__GT_str(error){
return cljs.repl.ex_str.call(null,cljs.repl.ex_triage.call(null,cljs.repl.Error__GT_map.call(null,error)));
});

//# sourceMappingURL=repl.js.map
