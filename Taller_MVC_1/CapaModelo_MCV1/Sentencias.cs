using System;
using System.Collections.Generic;
using System.Data.Odbc;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo_MCV1
{
    public class Sentencias
    {
        Conexion conn = new Conexion();
        public OdbcDataAdapter llenarTbl(string video)
        {
            string sSQL = "SELECT * FROM " + video + " ;";
            OdbcDataAdapter daSentencias = new OdbcDataAdapter(sSQL, conn.conexion());
            return daSentencias;
        }
    }
}
