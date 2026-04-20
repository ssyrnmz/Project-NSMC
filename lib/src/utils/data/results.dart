// Wrapper for results after retrieving or storing data
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.error(Exception error) = Error<T>;
}

// Subclass for Results with value
class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

// Subclass for Results with error
class Error<T> extends Result<T> {
  final Exception error;
  const Error(this.error);
}
