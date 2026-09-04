using CapaModelo_MCV1;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Odbc;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaControlador_MVC1
{
    public class Controlador
    {
        Sentencias sentencias = new Sentencias();
        public DataTable llenarDgv(String nombreTabla)
        {
            OdbcDataAdapter daControlador = sentencias.llenarTbl(nombreTabla);
            DataTable dtControlador = new DataTable();
            daControlador.Fill(dtControlador);
            return dtControlador;
        }
    }
}
