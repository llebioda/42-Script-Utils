# check_forbidden_calls.sh
Allows to check the unauthorized functions of the subject.

## Download

```bash
curl https://raw.githubusercontent.com/llebioda/42-Script-Utils/refs/heads/main/check_forbidden_calls.sh -O && chmod 744 check_forbidden_calls.sh
```

## Usage

./check_forbidden_calls.sh program_name [list of external function]

```bash
./check_forbidden_calls.sh program_name malloc printf free exit
```

Some forbidden functions might come from printf or other external functions, don't pay attention if you don't find them in the code.
