using System.Runtime.ExceptionServices;
using UnityEngine;

public class FloatingObject : MonoBehaviour
{
    public float speed = 3f;
    public float bounceForce = 2f;

    // hace la referencia al rigid para las fisicas del objeto
    private Rigidbody rb;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        rb.useGravity = false;
        // aqui le dice al que inicie en una velocidad aleatoria de manera random pero basandose en la variable de la speed eso ya depende en cuanto lo pongas en este caso la deje en 3, pero pienso cambiarlo maybe
        rb.linearVelocity = Random.onUnitSphere * speed;
    }

    void OnCollisionEnter(Collision collision)
    {
        // aqui calculamos la hacia donde rebota el object de esta manera tenemos la direccion en la que se esta moviendo, el angulo de choque y que rebote de regreso ya sea con la pared o con otro objeto que este flotando
        Vector3 newDir = Vector3.Reflect(rb.linearVelocity.normalized, collision.contacts[0].normal);
        // aqui le da un valor random a la direccion del robote para que sea mas natural y que de la sensacion de que es un objeto que esta por ahi flotando 
        newDir += Random.insideUnitSphere * 0.5f; 
        // aqui nomas el cambio de la velocidad del object con la nuva direccion y la speed que lleva el object 
        rb.linearVelocity = newDir.normalized * speed;
    }
}
