using System;
using System.Collections.Generic;
using System.Data.Odbc;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo_MCV1
{
    class Conexion
    {
    		public OdbcConnection conexion()
        {
            OdbcConnection conn = new OdbcConnection("Dsn=rentavideovhs");
            try
            {
                conn.Open();
            }

            catch (OdbcException)
            {
                Console.WriteLine("No conecto");
            }
            return conn;
        }
        public void desconexion(OdbcConnection conn)
        {
            try
            {
                conn.Close();
            }
            catch (OdbcException)
            {
                Console.WriteLine("No se desconecto");
            }
        }
    }
}
