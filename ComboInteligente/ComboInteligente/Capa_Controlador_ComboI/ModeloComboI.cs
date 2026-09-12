using Capa_Modelo_Combol.Repositorios;
using System;
using System.Data;

namespace Capa_Controlador_Combol
{
    public class ModeloComboI
    {
        RepositorioComboI sentencias = new RepositorioComboI();

        public DataTable enviarDatos(string _tabla, string _campo1, string _campo2)
        {
            var dtTabla = sentencias.obtenerDatos(_tabla, _campo1, _campo2);
            return dtTabla;
        }
    }
}