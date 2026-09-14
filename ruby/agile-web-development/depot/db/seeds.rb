# This file should ensure the existence of records required to run the
# application in every environment (production, development, test). The code
# here should be idempotent so that it can be executed at any point in every
# environment.
# The data can then be loaded with the bin/rails db:seed command (or
# created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# encoding: utf-8

Product.destroy_all
product = Product.create(title: 'Programming Ruby 3.3 (5th Edition)',
  description:
    %(<p>
      <em>The Pragmatic Programmers' Guide</em>
      Ruby is one of the most important programming languages in use for web
      development. It powers the Rails framework, which is the backing of some
      of the most important sites on the web. The Pickaxe Book, named for the
      tool on the cover, is the definitive reference on Ruby, a
      highly-regarded, fully object-oriented programming language. This updated
      edition is a comprehensive reference on the language itself, with a
      tutorial on the most important features of Ruby—including pattern
      matching and Ractors—and describes the language through Ruby 3.3.
    </p>),
  price: 33.95)

product.image.attach(io: File.open(
  Rails.root.join('db', 'images', 'ruby5-500.jpg')),
    filename: 'ruby5-500.jpg')

product.save!

product.translations.create!(locale: :de,
  description:
    %(<p>
      <em>Der Leitfaden der Pragmatic Programmers</em>
      Ruby ist eine der wichtigsten Programmiersprachen für die Webentwicklung.
      Es treibt das Rails-Framework an, das die Grundlage einiger der
      bedeutendsten Websites im Internet bildet. Das Pickaxe-Buch, benannt nach
      dem Werkzeug auf dem Cover, ist das maßgebliche Nachschlagewerk zu Ruby,
      einer hoch angesehenen, vollständig objektorientierten
      Programmiersprache. Diese aktualisierte Ausgabe ist ein umfassendes
      Nachschlagewerk zur Sprache selbst, mit einem Tutorial zu den
      wichtigsten Funktionen von Ruby – einschließlich Pattern Matching und
      Ractors – und beschreibt die Sprache bis einschließlich Ruby 3.3.
    </p>))

product.translations.create!(locale: :it,
  description:
    %(<p>
      <em>La Guida dei Pragmatic Programmers</em>
      Ruby è uno dei linguaggi di programmazione più importanti utilizzati
      per lo sviluppo web. Alimenta il framework Rails, che è alla base di
      alcuni dei siti più importanti del web. Il Pickaxe Book, chiamato così
      per lo strumento raffigurato in copertina, è il riferimento definitivo
      su Ruby, un linguaggio di programmazione pienamente orientato agli
      oggetti e molto apprezzato. Questa edizione aggiornata è un
      riferimento completo al linguaggio stesso, con un tutorial sulle
      funzionalità più importanti di Ruby, tra cui il pattern matching e i
      Ractor, e descrive il linguaggio fino a Ruby 3.3.
    </p>))

product.translations.create!(locale: :es,
  description:
    %(<p>
      <em>La Guía de los Pragmatic Programmers</em>
      Ruby es uno de los lenguajes de programación más importantes
      utilizados para el desarrollo web. Impulsa el framework Rails, que
      es la base de algunos de los sitios más importantes de la web. El
      Pickaxe Book, llamado así por la herramienta que aparece en la
      portada, es la referencia definitiva sobre Ruby, un lenguaje de
      programación muy valorado y totalmente orientado a objetos. Esta
      edición actualizada es una referencia completa sobre el propio
      lenguaje, con un tutorial sobre las características más importantes
      de Ruby —incluyendo pattern matching y Ractors— y describe el
      lenguaje hasta Ruby 3.3.
    </p>))
# . . .
product = Product.create(title: 'Rails Scales!',
  description:
    %(<p>
      <em>Practical Techniques for Performance and Growth</em>
      Rails doesn’t scale. So say the naysayers. They’re wrong. Ruby on Rails
      runs some of the biggest sites in the world, impacting the lives of
      millions of users while efficiently crunching petabytes of data. This
      book reveals how they do it, and how you can apply the same techniques
      to your applications. Optimize everything necessary to make an
      application function at scale: monitoring, product design, Ruby code,
      software architecture, database access, caching, and more. Even if your
      app may never have millions of users, you reduce the costs of hosting
      and maintaining it.
    </p>),
  price: 30.95)

  product.image.attach(io: File.open(
    Rails.root.join('db', 'images', 'cprpo.jpg')),
      filename: 'cprpo.jpg')

  product.save!

  product.translations.create!(locale: :de,
    description:
      %(<p>
        <em>Praktische Techniken für Leistung und Wachstum</em>
        Rails skaliert nicht. So behaupten es die Kritiker. Sie irren sich.
        Ruby on Rails betreibt einige der größten Websites der Welt und
        beeinflusst das Leben von Millionen Nutzern, während es effizient
        Petabytes an Daten verarbeitet. Dieses Buch zeigt, wie sie das
        schaffen und wie Sie dieselben Techniken auf Ihre eigenen
        Anwendungen anwenden können. Optimieren Sie alles, was nötig ist,
        damit eine Anwendung im großen Maßstab funktioniert: Monitoring,
        Produktdesign, Ruby-Code, Softwarearchitektur, Datenbankzugriff,
        Caching und mehr. Selbst wenn Ihre App nie Millionen Nutzer haben
        wird, senken Sie die Kosten für Hosting und Wartung.
      </p>))

  product.translations.create!(locale: :it,
    description:
      %(<p>
        <em>Tecniche Pratiche per Prestazioni e Crescita</em>
        Rails non scala. Così dicono i detrattori. Si sbagliano. Ruby on
        Rails fa funzionare alcuni dei siti più grandi al mondo,
        influenzando la vita di milioni di utenti elaborando in modo
        efficiente petabyte di dati. Questo libro rivela come ci riescono e
        come puoi applicare le stesse tecniche alle tue applicazioni.
        Ottimizza tutto ciò che serve per far funzionare un'applicazione su
        larga scala: monitoraggio, design del prodotto, codice Ruby,
        architettura software, accesso al database, caching e altro
        ancora. Anche se la tua app non avrà mai milioni di utenti, riduci
        comunque i costi di hosting e manutenzione.
      </p>))

  product.translations.create!(locale: :es,
    description:
      %(<p>
        <em>Técnicas Prácticas para el Rendimiento y el Crecimiento</em>
        Rails no escala. Eso dicen los detractores. Están equivocados.
        Ruby on Rails hace funcionar algunos de los sitios más grandes del
        mundo, impactando la vida de millones de usuarios mientras procesa
        eficientemente petabytes de datos. Este libro revela cómo lo
        logran y cómo puedes aplicar las mismas técnicas a tus propias
        aplicaciones. Optimiza todo lo necesario para que una aplicación
        funcione a gran escala: monitoreo, diseño de producto, código
        Ruby, arquitectura de software, acceso a bases de datos,
        almacenamiento en caché y mucho más. Aunque tu aplicación nunca
        llegue a tener millones de usuarios, reducirás los costos de
        alojamiento y mantenimiento.
      </p>))
# . . .

product = Product.create(title: 'Modern Front-End Development for Rails, Second Edition',
  description:
    %(<p>
      <em>Hotwire, Stimulus, Turbo, and React</em>
      Improve the user experience for your Rails app with rich, engaging
      client-side interactions. Learn to use the Rails 7 tools and simplify the
      complex JavaScript ecosystem. It’s easier than ever to build user
      interactions with Hotwire, Turbo, and Stimulus. You can add great
      front-end flair without much extra complication. Use React to build a
      more complex set of client-side features. Structure your code for
      different levels of client-side needs with these powerful options. Add to
      your toolkit today!
    </p>),
  price: 28.95)

product.image.attach(io: File.open(
  Rails.root.join('db', 'images', 'nrclient2.jpg')),
    filename: 'nrclient2.jpg')

product.save!

product.translations.create!(locale: :de,
  description:
    %(<p>
      <em>Hotwire, Stimulus, Turbo und React</em>
      Verbessern Sie die Benutzererfahrung Ihrer Rails-App mit
      reichhaltigen, ansprechenden clientseitigen Interaktionen. Lernen Sie,
      die Rails-7-Tools zu nutzen und das komplexe JavaScript-Ökosystem zu
      vereinfachen. Es war noch nie so einfach, Benutzerinteraktionen mit
      Hotwire, Turbo und Stimulus zu erstellen. Sie können großartigen
      Frontend-Schliff hinzufügen, ohne viel zusätzlichen Aufwand. Verwenden
      Sie React, um komplexere clientseitige Funktionen zu erstellen.
      Strukturieren Sie Ihren Code für unterschiedliche clientseitige
      Anforderungen mit diesen leistungsstarken Optionen. Erweitern Sie
      noch heute Ihr Werkzeugset!
    </p>))

product.translations.create!(locale: :it,
  description:
    %(<p>
      <em>Hotwire, Stimulus, Turbo e React</em>
      Migliora l'esperienza utente della tua app Rails con interazioni lato
      client ricche e coinvolgenti. Impara a usare gli strumenti di Rails 7
      e a semplificare il complesso ecosistema JavaScript. Non è mai stato
      così facile creare interazioni utente con Hotwire, Turbo e Stimulus.
      Puoi aggiungere un ottimo tocco front-end senza troppe complicazioni.
      Usa React per creare un insieme più complesso di funzionalità lato
      client. Struttura il tuo codice in base a diversi livelli di esigenze
      lato client con queste potenti opzioni. Aggiungi qualcosa in più al
      tuo kit di strumenti oggi stesso!
    </p>))

product.translations.create!(locale: :es,
  description:
    %(<p>
      <em>Hotwire, Stimulus, Turbo y React</em>
      Mejora la experiencia de usuario de tu aplicación Rails con
      interacciones del lado del cliente ricas y atractivas. Aprende a
      usar las herramientas de Rails 7 y a simplificar el complejo
      ecosistema de JavaScript. Nunca ha sido tan fácil crear
      interacciones de usuario con Hotwire, Turbo y Stimulus. Puedes
      añadir un gran estilo de front-end sin demasiada complicación
      adicional. Usa React para crear un conjunto más complejo de
      funcionalidades del lado del cliente. Estructura tu código según
      los distintos niveles de necesidades del lado del cliente con estas
      potentes opciones. ¡Suma esto a tu caja de herramientas hoy mismo!
    </p>))

User.find_or_create_by!(email_address: 'dave@example.org') do |user|
  user.name = 'dave'
  user.password = Rails.application.credentials.dave_password
end
