const redirectLogged = ({  }) => {
  const loginWithErrorOnClickHandler = () => {
    const err = new Error('Report caught error to New Relic');
    // window?.newrelic.noticeError(err);
    throw new Error('Third error for New Relic sourcemaps');
  };

  return (
    <div>
      <button type="button" onClick={loginWithErrorOnClickHandler}>
                Log in with ERROR2
      </button>
    </div>
  );
};

export default redirectLogged;
