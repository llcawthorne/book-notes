<a href="https://www.packtpub.com/en-us/unlock"><img src="https://drive.google.com/uc?export=view&id=1lQCTQQ8iV5pGuPA1n5wuds-3pwJi0OD_"></a>
<h1 align="center">
Rust Web Programming, Third Edition</h1>
<p align="center">This is the code repository for <a href ="https://www.packtpub.com/en-us/product/rust-web-programming-third-edition/9781835887769"> Rust Web Programming, Third Edition</a>, published by Packt.
</p>

<h2 align="center">
A hands-on guide to Rust for modern web development, with microservices and nanoservices
</h2>
<p align="center">
Maxwell Flitton</p>

<p align="center">
   <a href="https://packt.link/EaKXL" alt="Discord" title="Learn more on the Discord server"><img width="32px" src="https://cliply.co/wp-content/uploads/2021/08/372108630_DISCORD_LOGO_400.gif"/></a>
  &#8287;&#8287;&#8287;&#8287;&#8287;
  <a href="https://packt.link/free-ebook/9781835887769"><img width="32px" alt="Free PDF" title="Free PDF" src="https://cdn-icons-png.flaticon.com/512/4726/4726010.png"/></a>
 &#8287;&#8287;&#8287;&#8287;&#8287;
  <a href="https://packt.link/gbp/9781835887769"><img width="32px" alt="Graphic Bundle" title="Graphic Bundle" src="https://cdn-icons-png.flaticon.com/512/2659/2659360.png"/></a>
  &#8287;&#8287;&#8287;&#8287;&#8287;
   <a href="https://www.amazon.com/Rust-Web-Programming-hands-microservices/dp/B0D9QBNSVK/"><img width="32px" alt="Amazon" title="Get your copy" src="https://cdn-icons-png.flaticon.com/512/15466/15466027.png"/></a>
  &#8287;&#8287;&#8287;&#8287;&#8287;
</p>
<details open> 
  <summary><h2>About the book</summary>
<a href="https://www.packtpub.com/en-us/product/rust-web-programming-third-edition/9781835887769">
<img src="https://content.packt.com/B22086/cover_image_small.jpg" alt="Rust Web Programming, Third Edition" height="256px" align="right">
</a>

Rust is no longer just for systems programming. This book will show you why this safe and performant language is a crucial up-and-coming option for developing web applications, and get you on your way to building fully functional Rust web apps. You don’t need any experience with Rust to get started, and this new edition also comes with a shallower learning curve.

You’ll get hands-on with emerging Rust web frameworks including Actix, Axum, Rocket, and Hyper. You’ll look at injecting Rust into the frontend with WebAssembly and HTTPS configuration with NGINX. Later, you’ll move onto more advanced async topics, exploring TCP and framing, and implementing async systems.

As you work through the book, you’ll build a to-do application with authentication using a microservice architecture that compiles into one Rust binary, including the embedding of a frontend JavaScript application in the same binary. The application will have end-to-end atomic testing and a deployment pipeline.

By the end of this book, you’ll fully understand the significance of Rust for web development. You’ll also have the confidence to build robust, functional, and scalable Rust web applications from scratch.</details>
<details open> 
  <summary><h2>Key Learnings</summary>
<ul>

<li>Build scalable Rust web applications as monoliths or microservices</li>

<li>Develop a deeper understanding of async Rust</li>

<li>Get to grips with Rust language features like traits and the borrow checker</li>

<li>Manage authentication and databases in Rust web apps</li>

<li>Build app infrastructure on AWS using Terraform</li>

<li>Learn how to package and deploy Rust servers</li>

<li>Build unit tests and end-to-end tests for your Rust web apps with Python</li>

</ul>

  </details>

<details open> 
  <summary><h2>Chapters</summary>
     <img src="https://cliply.co/wp-content/uploads/2020/02/372002150_DOCUMENTS_400px.gif" alt="Unity Cookbook, Fifth Edition" height="556px" align="right">
<ol>

  <li>A Quick Introduction to Rust</li>

  <li>Useful Rust Patterns for Web Programming</li>

  <li>Designing Your Web Application in Rust</li>

  <li>Async Rust</li>

  <li>Handling HTTP Requests</li>

  <li>Processing HTTP Requests</li>

  <li>Displaying Content in the Browser</li>

  <li>Injecting Rust in the Frontend with WebAssembly</li>

  <li>Data Persistence with PostgreSQL</li>

  <li>Managing User Sessions</li>

  <li>Communicating Between Servers</li>

  <li>Caching Auth Sessions</li>

  <li>Observability Through Logging</li>

  <li>Unit Testing</li>

  <li>End-to-End Testing</li>

  <li>Deploying Our Application on AWS</li>

  <li>Configuring HTTPS with NGINX on AWS</li>

  <li>Practicalities of Using Microservices and Nanoservices</li>

  <li>Low-Level Networking</li>

  <li>Distributed Computing</li>

</ol>

</details>


<details open> 
  <summary><h2>Requirements for this book</summary>
You will need to know some basic concepts around HTML and CSS. You will also need to have some basic understanding of JavaScript. However, the HTML, CSS, and JavaScript is only needed for displaying data in the browser. If you are just reading the book to build backend API servers in Rust, then knowledge of HTML, CSS, and JavaScript is not needed.</br>
Some basic understanding of programming concepts such as functions and loops will also be needed as these will not be covered in the book.
</br>
<p>
<table>
  <tr><td><b>Software/hardware covered in the book</td><td><b>Operating system requirements</td></tr>
  <tr><td>Rust</td><td>Windows, macOS, or Linux (any)</td></tr>
  <tr><td>Node (for JavaScript)</td><td>Windows, macOS, or Linux (any)</td></tr>
  <tr><td>Python 3</td><td>Windows, macOS, or Linux (any)</td></tr>
  <tr><td>Docker</td><td>Windows, macOS, or Linux (any)</td></tr>
  <tr><td>docker-compose</td><td>Windows, macOS, or Linux (any)</td></tr>
  <tr><td>Postman</td><td>Windows, macOS, or Linux (any)</td></tr>
  <tr><td>Terraform</td><td>Windows, macOS, or Linux (any)</td></tr>
</table>

</br>
To take full advantage of the deployment on AWS chapters, you will need an AWS account, which might cost if you are not eligible for the Free Tier. However, the builds are automated with Terraform, so spinning up builds and tearing them down will be quick and easy, so you will not need to keep the infrastructure running while working through the book, keeping the costs to a minimum.</br>
By the of this book, you will have a solid foundation of building and deploying Rust servers. However, it must be noted that Rust is a powerful language. As this book focuses on web programming and deployment, there is scope for improvement in Rust programming aft er the book. Further reading on Rust is advised aft er the book to enable you to solve more complex problems.
  </details>
    


<details> 
  <summary><h2>Get to know the author</h2></summary>

_Maxwell Flitton_ is the CTO at Kioko, where he applies the engineering techniques present in this book to build production systems with 100% unit test coverage. Kioko is essentially Cursor for CAD, helping teams move faster from ideas to manufacturable geometry and working with Formula 1 teams on designing components for their cars.</br>
Maxwell previously worked in open-source fi nancial loss modeling at Oasis LMF. After that, he joined SurrealDB, where he helped build the database’s machine learning engine, before moving on to Kioko. He was also an early soft ware engineer at Monolith AI (since acquired by CoreWeave). Maxwell is an Honorary Researcher at King’s College London, applying Rust to computer vision for surgical robotics.</br>
In 2011, Maxwell earned a BSc in Nursing from the University of Lincoln (UK). While working 12-hour shifts in A&E departments, he completed a Physics degree with the Open University, followed by a Postgraduate Diploma in Physics and Engineering in Medicine at UCL (London).


</details>
<details> 
  <summary><h2>Other related books</h2></summary>
<ul>

  <li><a href="https://www.packtpub.com/en-us/product/learn-react-with-typescript-third-edition/9781836643173">Learn React with TypeScript, Third Edition</a></li>

  <li><a href="https://www.packtpub.com/en-us/product/learn-model-context-protocol-with-python-first-edition/9781806103232">Learn Model Context Protocol with Python, First Edition</a></li>
 
</ul>

</details>
