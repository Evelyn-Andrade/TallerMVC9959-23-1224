using Capa_Modelo_ComboI.Repositorios;
using System;
using System.Data;
using System.Data.Odbc;

namespace Capa_Modelo_Combol.Repositorios
{
    public class RepositorioComboI : Repositorio
    {
        public DataTable obtenerDatos(string _tabla, string _campo1, string _campo2)
        {
            string sql = "SELECT " + _campo1 + "," + _campo2 +
                         " FROM " + _tabla + " WHERE stock > 0;";

            OdbcCommand command = new OdbcCommand(sql, ObtenerConexion());
            OdbcDataAdapter adaptador = new OdbcDataAdapter(command);
            DataTable dtDatos = new DataTable();
            adaptador.Fill(dtDatos);
            return dtDatos;
        }
    }
}