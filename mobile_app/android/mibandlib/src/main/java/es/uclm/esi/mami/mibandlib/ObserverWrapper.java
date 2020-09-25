package es.uclm.esi.mami.mibandlib;

import io.reactivex.Emitter;
import io.reactivex.Observer;
import io.reactivex.disposables.Disposable;

class ObserverWrapper<T> implements Observer<T> {

    private final Emitter<T> emitter;

    public ObserverWrapper(Emitter<T> emitter) {
        this.emitter = emitter;
    }

    @Override
    public void onSubscribe(Disposable d) {
        // do nothing
    }

    @Override
    public void onNext(T value) {
        this.emitter.onNext(value);
    }

    @Override
    public void onError(Throwable e) {
        this.emitter.onError(e);
    }

    @Override
    public void onComplete() {
        this.emitter.onComplete();
    }
}