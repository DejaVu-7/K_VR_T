using UnityEngine;

public class FloatingObject : MonoBehaviour
{
    public float speed = 3f;
    public float bounceForce = 2f;

    private Rigidbody rb;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        rb.useGravity = false;
        rb.linearVelocity = Random.onUnitSphere * speed;
    }

    void OnCollisionEnter(Collision collision)
    {
        // Rebote aleatorio
        Vector3 newDir = Vector3.Reflect(rb.linearVelocity.normalized, collision.contacts[0].normal);
        newDir += Random.insideUnitSphere * 0.5f; // Agrega aleatoriedad
        rb.linearVelocity = newDir.normalized * speed;
    }
}
