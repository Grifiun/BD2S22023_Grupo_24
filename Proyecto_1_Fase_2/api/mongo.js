const user = "admin";
const password = "admin";
const host = "localhost"; // o la dirección de tu servidor MongoDB
const port = 27017; // el puerto de MongoDB
const database = "Fase2";

const connectionString = `mongodb://${user}:${password}@${host}:${port}/${database}`;
console.log(connectionString);


mongodb://admin:admin@localhost:27017/fase2?authSource=admin
mongosh --host localhost --port 27017 --username admin --password admin --authenticationDatabase admin


// Mongo Cloud
//mongodb+srv://rootuser:GXDzYTUiDzEY6Py4@mongocluster.pycs6zw.mongodb.net/
//mongodb+srv://rootuser:*****@mongocluster.pycs6zw.mongodb.net/

Create DB fase2
	$ use fase2
	
Create user
	$ db.createUser({
	  user: "user",
	  pwd: "admin",
	  roles: [
		{
		  role: "readWrite",
		  db: "fase2" // Nombre de la base de datos a la que se otorga acceso
		}
	  ]
	})

View
	$ db.getUsers()
