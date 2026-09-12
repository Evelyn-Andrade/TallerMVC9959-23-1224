using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using CapaControlador_prototipoumg2k26;

namespace CapaVista_prototipoumg2k26.Formas
{
    public partial class FrmVideo : Form
    {
        private ModeloVideo video = new ModeloVideo();

        public FrmVideo()
        {
            InitializeComponent();
            panIngresoDatos.Enabled = false;
            listaVideos();
        }

        private void FrmVideo_Load(object sender, EventArgs e)
        {
            listaVideos();
        }

        private void listaVideos()
        {
            try
            {
                dgvVideos.DataSource = video.GetAll();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString());
            }
        }

        private void btnBuscar_Click(object sender, EventArgs e)
        {
            dgvVideos.DataSource = video.FindbyId(txtSearch.Text);
        }

        private void txtSearch_TextChanged(object sender, EventArgs e)
        {
            dgvVideos.DataSource = video.FindbyId(txtSearch.Text);
        }

        private void btnGrabar_Click(object sender, EventArgs e)
        {
            video.Titulo = txtTitulo.Text;
            video.Genero = txtGenero.Text;
            video.PrecioRenta = Convert.ToDecimal(txtPrecioRenta.Text);
            video.Stock = Convert.ToInt32(txtStock.Text);
            video.EstadoVideo = txtEstadoVideo.Text;
            video.Codigo = txtCodigo.Text;
            video.Director = txtDirector.Text;
            video.Anio = Convert.ToInt32(txtAnio.Text);
            video.Clasificacion = txtClasificacion.Text;
            video.Duracion = Convert.ToInt32(txtDuracion.Text);
            video.Idioma = txtIdioma.Text;

            bool valido = new Ayudas.ValidacionDatos(video).Validar();
            if (valido == true)
            {
                string resultado = video.GrabarCambios();
                MessageBox.Show(resultado);
                listaVideos();
                Reinicio();
            }
        }

        private void Reinicio()
        {
            panIngresoDatos.Enabled = false;
            txtIdVideo.Clear();
            txtTitulo.Clear();
            txtGenero.Clear();
            txtPrecioRenta.Clear();
            txtStock.Clear();
            txtEstadoVideo.Clear();
            txtCodigo.Clear();
            txtDirector.Clear();
            txtAnio.Clear();
            txtClasificacion.Clear();
            txtDuracion.Clear();
            txtIdioma.Clear();
        }

        private void btnNuevo_Click(object sender, EventArgs e)
        {
            panIngresoDatos.Enabled = true;
            video.Estado = EstadoEntidad.Added;
        }

        private void btnEditar_Click(object sender, EventArgs e)
        {
            if (dgvVideos.SelectedRows.Count > 0)
            {
                panIngresoDatos.Enabled = true;
                video.Estado = EstadoEntidad.Modified;
                video.IdVideo = Convert.ToInt32(dgvVideos.CurrentRow.Cells[0].Value);
                txtIdVideo.Text = dgvVideos.CurrentRow.Cells[0].Value.ToString();
                txtTitulo.Text = dgvVideos.CurrentRow.Cells[1].Value.ToString();
                txtGenero.Text = dgvVideos.CurrentRow.Cells[2].Value.ToString();
                txtPrecioRenta.Text = dgvVideos.CurrentRow.Cells[3].Value.ToString();
                txtStock.Text = dgvVideos.CurrentRow.Cells[4].Value.ToString();
                txtEstadoVideo.Text = dgvVideos.CurrentRow.Cells[5].Value.ToString();
                txtCodigo.Text = dgvVideos.CurrentRow.Cells[6].Value.ToString();
                txtDirector.Text = dgvVideos.CurrentRow.Cells[7].Value.ToString();
                txtAnio.Text = dgvVideos.CurrentRow.Cells[8].Value.ToString();
                txtClasificacion.Text = dgvVideos.CurrentRow.Cells[9].Value.ToString();
                txtDuracion.Text = dgvVideos.CurrentRow.Cells[10].Value.ToString();
                txtIdioma.Text = dgvVideos.CurrentRow.Cells[11].Value.ToString();
            }
            else MessageBox.Show("Seleccione una fila");
        }

        private void btnBorrar_Click(object sender, EventArgs e)
        {
            if (dgvVideos.SelectedRows.Count > 0)
            {
                video.Estado = EstadoEntidad.Deleted;
                video.IdVideo = Convert.ToInt32(dgvVideos.CurrentRow.Cells[0].Value);
                string resultado = video.GrabarCambios();
                MessageBox.Show(resultado);
                listaVideos();
            }
            else MessageBox.Show("Seleccione una fila");
        }
    }
}