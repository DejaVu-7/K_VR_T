using UnityEngine;

public class AudioTrigger : MonoBehaviour
{
    public AudioClip audioClip;
    private bool hasPlayed = false;

    private void OnTriggerEnter(Collider other)
    {
        if (hasPlayed) return;
        if (other.CompareTag("Player"))
        {
            AudioManager.Instance.QueueAudio(audioClip);
            hasPlayed = true;
        }
    }
}
