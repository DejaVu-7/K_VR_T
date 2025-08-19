using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance;
    private AudioSource audioSource;
    private Queue<AudioClip> audioQueue = new Queue<AudioClip>();
    private bool isPlaying = false;
    public float fadeDuration = 1f;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }

        audioSource = GetComponent<AudioSource>();
    }

    public void QueueAudio(AudioClip clip)
    {
        if (clip == null) return;
        audioQueue.Enqueue(clip);
        if (!isPlaying)
        {
            StartCoroutine(PlayQueue());
        }
    }

    private IEnumerator PlayQueue()
    {
        isPlaying = true;
        while (audioQueue.Count > 0)
        {
            AudioClip clip = audioQueue.Dequeue();
            yield return StartCoroutine(PlayAudioWithFade(clip));
        }
        isPlaying = false;
    }

    private IEnumerator PlayAudioWithFade(AudioClip clip)
    {
        audioSource.clip = clip;
        audioSource.volume = 0f;
        audioSource.Play();

        float t = 0f;
        while (t < fadeDuration)
        {
            audioSource.volume = Mathf.Lerp(0f, 1f, t / fadeDuration);
            t += Time.deltaTime;
            yield return null;
        }
        audioSource.volume = 1f;

        yield return new WaitForSeconds(clip.length - 2 * fadeDuration);

        t = 0f;
        while (t < fadeDuration)
        {
            audioSource.volume = Mathf.Lerp(1f, 0f, t / fadeDuration);
            t += Time.deltaTime;
            yield return null;
        }
        audioSource.Stop();
    }
}
