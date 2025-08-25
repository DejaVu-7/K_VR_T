using UnityEngine;

public class OneWayWallPermanent : MonoBehaviour
{
    [Header("Objeto con Collider sólido que reemplazará al trigger")]
    public GameObject solidWall;

    [Header("Otra pared que se deshabilitará")]
    public GameObject wallToDisable;

    private bool hasCrossed = false;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player") && !hasCrossed)
        {
            // Activa la pared sólida (bloquea el camino)
            if (solidWall != null)
            {
                solidWall.SetActive(true);
            }

            // Desactiva la otra pared
            if (wallToDisable != null)
            {
                wallToDisable.SetActive(false);
            }

            // Desactiva este trigger (para que no vuelva a funcionar)
            gameObject.SetActive(false);

            hasCrossed = true;
        }
    }
}
